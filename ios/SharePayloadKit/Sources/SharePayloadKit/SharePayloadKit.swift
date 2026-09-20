import Foundation
import CryptoKit

public enum SharedCaptureSourceHint: String, Codable, Equatable, Sendable {
  case text
  case url
}

public enum DurableImportError: Error {
  case invalidEnvelope
  case invalidQueueEntry
}

public struct SharedCaptureEnvelope: Codable, Equatable, Sendable {
  public static let currentSchemaVersion = 1
  public static let maximumCandidateURLCount = 4
  public static let maximumURLLength = 4_096

  public let schemaVersion: Int
  public let handoffID: UUID
  public let receivedAt: Date
  public let sourceHint: SharedCaptureSourceHint
  public let rawText: String?
  public let candidateURLs: [String]

  public init(
    schemaVersion: Int = currentSchemaVersion,
    handoffID: UUID = UUID(),
    receivedAt: Date,
    sourceHint: SharedCaptureSourceHint,
    rawText: String?,
    candidateURLs: [String]
  ) throws {
    self.schemaVersion = schemaVersion
    self.handoffID = handoffID
    self.receivedAt = receivedAt
    self.sourceHint = sourceHint
    self.rawText = rawText
    self.candidateURLs = candidateURLs
    try validate()
  }

  public func validate() throws {
    guard schemaVersion == Self.currentSchemaVersion,
      (1...Self.maximumCandidateURLCount).contains(candidateURLs.count),
      rawText?.count ?? 0 <= PayloadInspector.maximumTextLength,
      (sourceHint == .text) == (rawText != nil),
      candidateURLs.allSatisfy({ candidate in
        guard candidate.count <= Self.maximumURLLength, let url = URL(string: candidate),
          let scheme = url.scheme?.lowercased()
        else { return false }
        return (scheme == "http" || scheme == "https") && url.host != nil
      })
    else { throw DurableImportError.invalidEnvelope }
  }
}

public struct QueuedHandoff: Equatable, Sendable {
  public let envelope: SharedCaptureEnvelope
  fileprivate let fileURL: URL
}

public struct HandoffQueueScan: Equatable, Sendable {
  public let entries: [QueuedHandoff]
  public let rejectedCount: Int
  public let totalPendingCount: Int
}

public struct HandoffQueue: Sendable {
  public static let maximumEnvelopeBytes = 32 * 1_024
  public static let maximumEntriesPerScan = 100

  private let directoryURL: URL

  public init(directoryURL: URL) {
    self.directoryURL = directoryURL.standardizedFileURL
  }

  public func enqueue(_ envelope: SharedCaptureEnvelope) throws {
    try envelope.validate()
    let data = try Self.encoder.encode(envelope)
    guard data.count <= Self.maximumEnvelopeBytes else {
      throw DurableImportError.invalidEnvelope
    }
    try FileManager.default.createDirectory(
      at: directoryURL,
      withIntermediateDirectories: true
    )
    let destination = directoryURL.appendingPathComponent(Self.fileName(for: envelope.handoffID))
    let temporary = directoryURL.appendingPathComponent(".\(UUID().uuidString).tmp")
    defer { try? FileManager.default.removeItem(at: temporary) }
    try data.write(to: temporary, options: .withoutOverwriting)
    try FileManager.default.moveItem(at: temporary, to: destination)
  }

  public func pendingEntries() throws -> [QueuedHandoff] {
    try scan().entries
  }

  public func scan() throws -> HandoffQueueScan {
    guard FileManager.default.fileExists(atPath: directoryURL.path) else {
      return HandoffQueueScan(entries: [], rejectedCount: 0, totalPendingCount: 0)
    }
    let files = try FileManager.default.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey, .isSymbolicLinkKey]
    ).filter { $0.pathExtension == "json" }.sorted { $0.lastPathComponent < $1.lastPathComponent }

    var entries: [QueuedHandoff] = []
    var rejectedCount = 0
    for fileURL in files.prefix(Self.maximumEntriesPerScan) {
      do {
        let values = try fileURL.resourceValues(
          forKeys: [.fileSizeKey, .isRegularFileKey, .isSymbolicLinkKey]
        )
        guard values.isRegularFile == true, values.isSymbolicLink != true,
          let size = values.fileSize, size <= Self.maximumEnvelopeBytes
        else { throw DurableImportError.invalidQueueEntry }
        let envelope = try Self.decoder.decode(
          SharedCaptureEnvelope.self,
          from: Data(contentsOf: fileURL, options: .mappedIfSafe)
        )
        try envelope.validate()
        guard fileURL.lastPathComponent == Self.fileName(for: envelope.handoffID) else {
          throw DurableImportError.invalidQueueEntry
        }
        entries.append(QueuedHandoff(envelope: envelope, fileURL: fileURL))
      } catch {
        rejectedCount += 1
      }
    }
    return HandoffQueueScan(
      entries: entries,
      rejectedCount: rejectedCount,
      totalPendingCount: files.count
    )
  }

  public func acknowledge(_ entry: QueuedHandoff) throws {
    guard entry.fileURL.deletingLastPathComponent().standardizedFileURL
      .resolvingSymlinksInPath() == directoryURL.resolvingSymlinksInPath(),
      entry.fileURL.lastPathComponent == Self.fileName(for: entry.envelope.handoffID)
    else { throw DurableImportError.invalidQueueEntry }
    try FileManager.default.removeItem(at: entry.fileURL)
  }

  private static let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    return encoder
  }()

  private static let decoder = JSONDecoder()

  private static func fileName(for handoffID: UUID) -> String {
    "\(handoffID.uuidString).json"
  }
}

public enum SpikeCaptureStatus: String, Codable, Equatable, Sendable {
  case unassigned
}

public struct SpikeCapture: Codable, Equatable, Sendable {
  public let id: UUID
  public let payloadFingerprint: String
  public let originalHandoffID: UUID
  public let capturedAt: Date
  public let status: SpikeCaptureStatus
}

public struct SpikeCaptureSaveResult: Equatable, Sendable {
  public let capture: SpikeCapture
  public let inserted: Bool
}

public struct SpikeCaptureRepository: Sendable {
  private static let maximumCaptureBytes = 4 * 1_024
  private let directoryURL: URL

  public init(directoryURL: URL) {
    self.directoryURL = directoryURL.standardizedFileURL
  }

  public func save(_ envelope: SharedCaptureEnvelope) throws -> SpikeCaptureSaveResult {
    try envelope.validate()
    let fingerprint = try Self.fingerprint(for: envelope)
    try FileManager.default.createDirectory(
      at: directoryURL,
      withIntermediateDirectories: true
    )
    let destination = directoryURL.appendingPathComponent("\(fingerprint).json")
    if FileManager.default.fileExists(atPath: destination.path) {
      return SpikeCaptureSaveResult(capture: try loadCapture(at: destination), inserted: false)
    }

    let capture = SpikeCapture(
      id: UUID(),
      payloadFingerprint: fingerprint,
      originalHandoffID: envelope.handoffID,
      capturedAt: envelope.receivedAt,
      status: .unassigned
    )
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    let data = try encoder.encode(capture)
    guard data.count <= Self.maximumCaptureBytes else {
      throw DurableImportError.invalidEnvelope
    }
    let temporary = directoryURL.appendingPathComponent(".\(UUID().uuidString).tmp")
    defer { try? FileManager.default.removeItem(at: temporary) }
    try data.write(to: temporary, options: .withoutOverwriting)
    do {
      try FileManager.default.moveItem(at: temporary, to: destination)
      return SpikeCaptureSaveResult(capture: capture, inserted: true)
    } catch where FileManager.default.fileExists(atPath: destination.path) {
      return SpikeCaptureSaveResult(capture: try loadCapture(at: destination), inserted: false)
    }
  }

  public func allCaptures() throws -> [SpikeCapture] {
    guard FileManager.default.fileExists(atPath: directoryURL.path) else { return [] }
    return try FileManager.default.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey]
    ).filter { $0.pathExtension == "json" }.sorted {
      $0.lastPathComponent < $1.lastPathComponent
    }.map(loadCapture(at:))
  }

  private func loadCapture(at fileURL: URL) throws -> SpikeCapture {
    let values = try fileURL.resourceValues(
      forKeys: [.fileSizeKey, .isRegularFileKey, .isSymbolicLinkKey]
    )
    guard values.isRegularFile == true, values.isSymbolicLink != true,
      let size = values.fileSize, size <= Self.maximumCaptureBytes
    else { throw DurableImportError.invalidQueueEntry }
    let capture = try JSONDecoder().decode(
      SpikeCapture.self,
      from: Data(contentsOf: fileURL, options: .mappedIfSafe)
    )
    guard capture.status == .unassigned,
      fileURL.lastPathComponent == "\(capture.payloadFingerprint).json"
    else { throw DurableImportError.invalidQueueEntry }
    return capture
  }

  private static func fingerprint(for envelope: SharedCaptureEnvelope) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    let data = try encoder.encode(
      PayloadFingerprintMaterial(
        sourceHint: envelope.sourceHint,
        rawText: envelope.rawText,
        candidateURLs: envelope.candidateURLs
      ))
    return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
  }
}

public struct ImportSummary: Equatable, Sendable {
  public let pendingCount: Int
  public let captureCount: Int
  public let importedCount: Int
  public let duplicateCount: Int
  public let rejectedCount: Int
  public let queueFailureCount: Int
  public let repositoryFailureCount: Int
  public let acknowledgementFailureCount: Int
  public let optionalFailureCount: Int

  public var status: String {
    if queueFailureCount + repositoryFailureCount + acknowledgementFailureCount > 0 {
      return "retry_required"
    }
    if rejectedCount > 0 { return "invalid_pending" }
    if optionalFailureCount > 0 { return "saved_optional_failed" }
    if importedCount + duplicateCount > 0 { return "imported" }
    return "idle"
  }

  public var propertyList: [String: Any] {
    [
      "schemaVersion": 1,
      "status": status,
      "pendingCount": pendingCount,
      "captureCount": captureCount,
      "importedCount": importedCount,
      "duplicateCount": duplicateCount,
      "rejectedCount": rejectedCount,
      "queueFailureCount": queueFailureCount,
      "repositoryFailureCount": repositoryFailureCount,
      "acknowledgementFailureCount": acknowledgementFailureCount,
      "optionalFailureCount": optionalFailureCount,
    ]
  }
}

public struct HandoffImporter: Sendable {
  private let queue: HandoffQueue
  private let repository: SpikeCaptureRepository

  public init(queue: HandoffQueue, repository: SpikeCaptureRepository) {
    self.queue = queue
    self.repository = repository
  }

  public func importPending(
    optionalOperation: (SpikeCapture) throws -> Void = { _ in }
  ) -> ImportSummary {
    let scan: HandoffQueueScan
    do {
      scan = try queue.scan()
    } catch {
      return summary(queueFailureCount: 1)
    }

    var importedCount = 0
    var duplicateCount = 0
    var repositoryFailureCount = 0
    var acknowledgementFailureCount = 0
    var optionalFailureCount = 0
    var acknowledgedCount = 0
    for entry in scan.entries {
      let saved: SpikeCaptureSaveResult
      do {
        saved = try repository.save(entry.envelope)
        if saved.inserted { importedCount += 1 } else { duplicateCount += 1 }
      } catch {
        repositoryFailureCount += 1
        continue
      }
      do {
        try queue.acknowledge(entry)
        acknowledgedCount += 1
      } catch {
        acknowledgementFailureCount += 1
        continue
      }
      do {
        try optionalOperation(saved.capture)
      } catch {
        optionalFailureCount += 1
      }
    }

    return ImportSummary(
      pendingCount: scan.totalPendingCount - acknowledgedCount,
      captureCount: (try? repository.allCaptures().count) ?? 0,
      importedCount: importedCount,
      duplicateCount: duplicateCount,
      rejectedCount: scan.rejectedCount,
      queueFailureCount: 0,
      repositoryFailureCount: repositoryFailureCount,
      acknowledgementFailureCount: acknowledgementFailureCount,
      optionalFailureCount: optionalFailureCount
    )
  }

  private func summary(queueFailureCount: Int) -> ImportSummary {
    ImportSummary(
      pendingCount: 0,
      captureCount: (try? repository.allCaptures().count) ?? 0,
      importedCount: 0,
      duplicateCount: 0,
      rejectedCount: 0,
      queueFailureCount: queueFailureCount,
      repositoryFailureCount: 0,
      acknowledgementFailureCount: 0,
      optionalFailureCount: 0
    )
  }
}

private struct PayloadFingerprintMaterial: Encodable {
  let sourceHint: SharedCaptureSourceHint
  let rawText: String?
  let candidateURLs: [String]
}

public enum ShareSourceType: String, Equatable, Sendable {
  case text
  case unsupported
  case url
}

public enum ShareHostCategory: String, Equatable, Sendable {
  case instagram
  case other
  case none
}

public enum ShareRejectionReason: String, Equatable, Sendable {
  case noHTTPURL = "no_http_url"
  case textTooLarge = "text_too_large"
  case unsupportedScheme = "unsupported_scheme"
  case unsupportedType = "unsupported_type"
}

public struct ShareEvidence: Equatable, Sendable {
  public let representationSupported: Bool
  public let sourceType: ShareSourceType
  public let characterCount: Int
  public let urlCount: Int
  public let hostCategory: ShareHostCategory
  public let rejectionReason: ShareRejectionReason?
  public let receivedAt: Date

  public var propertyList: [String: Any] {
    var value: [String: Any] = [
      "schemaVersion": 1,
      "representationSupported": representationSupported,
      "sourceType": sourceType.rawValue,
      "characterCount": characterCount,
      "urlCount": urlCount,
      "hostCategory": hostCategory.rawValue,
      "receivedAt": ISO8601DateFormatter().string(from: receivedAt),
    ]
    if let rejectionReason {
      value["rejectionReason"] = rejectionReason.rawValue
    }
    return value
  }

  public static func == (lhs: ShareEvidence, rhs: ShareEvidence) -> Bool {
    lhs.representationSupported == rhs.representationSupported
      && lhs.sourceType == rhs.sourceType
      && lhs.characterCount == rhs.characterCount
      && lhs.urlCount == rhs.urlCount
      && lhs.hostCategory == rhs.hostCategory
      && lhs.rejectionReason == rhs.rejectionReason
      && lhs.receivedAt == rhs.receivedAt
  }
}

public enum PayloadInspector {
  public static let maximumTextLength = 4_096

  public static func unsupported(receivedAt: Date = Date()) -> ShareEvidence {
    ShareEvidence(
      representationSupported: false,
      sourceType: .unsupported,
      characterCount: 0,
      urlCount: 0,
      hostCategory: .none,
      rejectionReason: .unsupportedType,
      receivedAt: receivedAt
    )
  }

  public static func inspect(url: URL, receivedAt: Date = Date()) -> ShareEvidence {
    guard isHTTP(url), url.host != nil else {
      return ShareEvidence(
        representationSupported: false,
        sourceType: .url,
        characterCount: url.absoluteString.count,
        urlCount: 0,
        hostCategory: .none,
        rejectionReason: .unsupportedScheme,
        receivedAt: receivedAt
      )
    }

    return ShareEvidence(
      representationSupported: true,
      sourceType: .url,
      characterCount: url.absoluteString.count,
      urlCount: 1,
      hostCategory: hostCategory(for: url),
      rejectionReason: nil,
      receivedAt: receivedAt
    )
  }

  public static func inspect(text: String, receivedAt: Date = Date()) -> ShareEvidence {
    guard text.count <= maximumTextLength else {
      return ShareEvidence(
        representationSupported: false,
        sourceType: .text,
        characterCount: text.count,
        urlCount: 0,
        hostCategory: .none,
        rejectionReason: .textTooLarge,
        receivedAt: receivedAt
      )
    }

    let urls = detectedHTTPURLs(in: text)
    guard !urls.isEmpty else {
      return ShareEvidence(
        representationSupported: false,
        sourceType: .text,
        characterCount: text.count,
        urlCount: 0,
        hostCategory: .none,
        rejectionReason: .noHTTPURL,
        receivedAt: receivedAt
      )
    }

    let category: ShareHostCategory =
      urls.contains { hostCategory(for: $0) == .instagram }
      ? .instagram
      : .other
    return ShareEvidence(
      representationSupported: true,
      sourceType: .text,
      characterCount: text.count,
      urlCount: urls.count,
      hostCategory: category,
      rejectionReason: nil,
      receivedAt: receivedAt
    )
  }

  private static func detectedHTTPURLs(in text: String) -> [URL] {
    guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    else { return [] }
    let range = NSRange(text.startIndex..<text.endIndex, in: text)
    return detector.matches(in: text, range: range).compactMap(\.url).filter(isHTTP)
  }

  private static func isHTTP(_ url: URL) -> Bool {
    guard let scheme = url.scheme?.lowercased() else { return false }
    return scheme == "http" || scheme == "https"
  }

  private static func hostCategory(for url: URL) -> ShareHostCategory {
    guard let host = url.host?.lowercased() else { return .none }
    return host == "instagram.com" || host.hasSuffix(".instagram.com") ? .instagram : .other
  }
}

public enum EvidenceSelector {
  public static func select(_ candidates: [ShareEvidence]) -> ShareEvidence {
    candidates.first(where: \.representationSupported)
      ?? candidates.first
      ?? PayloadInspector.unsupported()
  }
}
