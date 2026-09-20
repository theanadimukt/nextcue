import Foundation

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
