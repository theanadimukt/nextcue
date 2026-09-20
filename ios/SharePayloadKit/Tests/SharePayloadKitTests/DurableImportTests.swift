import Foundation
import XCTest

@testable import SharePayloadKit

final class DurableImportTests: XCTestCase {
  func testEnqueuedEnvelopeSurvivesQueueReconstruction() throws {
    let directory = try temporaryDirectory()
    let envelope = try SharedCaptureEnvelope(
      handoffID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
      receivedAt: Date(timeIntervalSince1970: 1_700_000_000),
      sourceHint: .text,
      rawText: "Watch https://instagram.com/reel/example",
      candidateURLs: ["https://instagram.com/reel/example"]
    )

    try HandoffQueue(directoryURL: directory).enqueue(envelope)

    let entries = try HandoffQueue(directoryURL: directory).pendingEntries()
    XCTAssertEqual(entries.map(\.envelope), [envelope])
    do {
      try HandoffQueue(directoryURL: directory).acknowledge(try XCTUnwrap(entries.first))
    } catch {
      XCTFail("Acknowledgement failed: \(error)")
    }
    XCTAssertEqual(try HandoffQueue(directoryURL: directory).pendingEntries(), [])
  }

  func testQueueWriteFailureDoesNotCreatePendingWork() throws {
    let parent = try temporaryDirectory()
    let blockingFile = parent.appendingPathComponent("not-a-directory")
    try Data().write(to: blockingFile)
    let queue = HandoffQueue(directoryURL: blockingFile.appendingPathComponent("pending"))
    let envelope = try SharedCaptureEnvelope(
      receivedAt: Date(timeIntervalSince1970: 1_700_000_000),
      sourceHint: .url,
      rawText: nil,
      candidateURLs: ["https://instagram.com/reel/example"]
    )

    XCTAssertThrowsError(try queue.enqueue(envelope))
    XCTAssertEqual(try queue.pendingEntries(), [])
  }

  func testEnvelopeRejectsUnboundedOrUnsupportedInput() throws {
    XCTAssertThrowsError(
      try SharedCaptureEnvelope(
        receivedAt: Date(),
        sourceHint: .text,
        rawText: String(repeating: "a", count: PayloadInspector.maximumTextLength + 1),
        candidateURLs: ["https://instagram.com/reel/example"]
      ))
    XCTAssertThrowsError(
      try SharedCaptureEnvelope(
        receivedAt: Date(),
        sourceHint: .url,
        rawText: nil,
        candidateURLs: ["file:///private/example"]
      ))
  }

  func testCrashAfterRepositorySaveReplaysWithoutCreatingDuplicate() throws {
    let root = try temporaryDirectory()
    let queue = HandoffQueue(directoryURL: root.appendingPathComponent("pending"))
    let repository = SpikeCaptureRepository(
      directoryURL: root.appendingPathComponent("captures"))
    try queue.enqueue(try envelope())
    let pending = try XCTUnwrap(queue.pendingEntries().first)

    _ = try repository.save(pending.envelope)

    let summary = HandoffImporter(queue: queue, repository: repository).importPending()
    XCTAssertEqual(summary.importedCount, 0)
    XCTAssertEqual(summary.duplicateCount, 1)
    XCTAssertEqual(summary.pendingCount, 0)
    XCTAssertEqual(try repository.allCaptures().count, 1)
  }

  func testIdenticalPayloadsProduceOneLogicalCapture() throws {
    let root = try temporaryDirectory()
    let queue = HandoffQueue(directoryURL: root.appendingPathComponent("pending"))
    let repository = SpikeCaptureRepository(
      directoryURL: root.appendingPathComponent("captures"))
    try queue.enqueue(try envelope(handoffID: UUID()))
    try queue.enqueue(try envelope(handoffID: UUID()))

    let summary = HandoffImporter(queue: queue, repository: repository).importPending()

    XCTAssertEqual(summary.importedCount, 1)
    XCTAssertEqual(summary.duplicateCount, 1)
    XCTAssertEqual(summary.pendingCount, 0)
    XCTAssertEqual(try repository.allCaptures().count, 1)
  }

  func testRepositoryFailureLeavesQueueItemPending() throws {
    let root = try temporaryDirectory()
    let queue = HandoffQueue(directoryURL: root.appendingPathComponent("pending"))
    try queue.enqueue(try envelope())
    let blockingFile = root.appendingPathComponent("not-a-directory")
    try Data().write(to: blockingFile)
    let repository = SpikeCaptureRepository(
      directoryURL: blockingFile.appendingPathComponent("captures"))

    let summary = HandoffImporter(queue: queue, repository: repository).importPending()

    XCTAssertEqual(summary.repositoryFailureCount, 1)
    XCTAssertEqual(summary.pendingCount, 1)
    XCTAssertEqual(try queue.pendingEntries().count, 1)
  }

  func testOptionalFailureLeavesPersistedCaptureUnassigned() throws {
    let root = try temporaryDirectory()
    let queue = HandoffQueue(directoryURL: root.appendingPathComponent("pending"))
    let repository = SpikeCaptureRepository(
      directoryURL: root.appendingPathComponent("captures"))
    try queue.enqueue(try envelope())

    let summary = HandoffImporter(queue: queue, repository: repository).importPending {
      _ in throw SimulatedFailure()
    }

    XCTAssertEqual(summary.optionalFailureCount, 1)
    XCTAssertEqual(summary.pendingCount, 0)
    XCTAssertEqual(try repository.allCaptures().map(\.status), [.unassigned])
  }

  func testCorruptAndUnsupportedQueueDataRemainUnacknowledged() throws {
    let root = try temporaryDirectory()
    let queueDirectory = root.appendingPathComponent("pending")
    try FileManager.default.createDirectory(at: queueDirectory, withIntermediateDirectories: true)
    try Data("not-json".utf8).write(to: queueDirectory.appendingPathComponent("corrupt.json"))
    let unsupported = try envelope(handoffID: UUID())
    let encoded = try JSONEncoder().encode(unsupported)
    let unsupportedData = try XCTUnwrap(
      String(data: encoded, encoding: .utf8)?.replacingOccurrences(
        of: "\"schemaVersion\":1",
        with: "\"schemaVersion\":99"
      ).data(using: .utf8))
    try unsupportedData.write(
      to: queueDirectory.appendingPathComponent("\(unsupported.handoffID.uuidString).json"))
    let repository = SpikeCaptureRepository(
      directoryURL: root.appendingPathComponent("captures"))

    let summary = HandoffImporter(
      queue: HandoffQueue(directoryURL: queueDirectory),
      repository: repository
    ).importPending()

    XCTAssertEqual(summary.rejectedCount, 2)
    XCTAssertEqual(summary.pendingCount, 2)
    XCTAssertEqual(try repository.allCaptures(), [])
    XCTAssertFalse(summary.propertyList.description.contains("instagram.com"))
    XCTAssertFalse(summary.propertyList.description.contains(root.path))
  }

  private func envelope(handoffID: UUID = UUID()) throws -> SharedCaptureEnvelope {
    try SharedCaptureEnvelope(
      handoffID: handoffID,
      receivedAt: Date(timeIntervalSince1970: 1_700_000_000),
      sourceHint: .text,
      rawText: "Watch https://instagram.com/reel/example",
      candidateURLs: ["https://instagram.com/reel/example"]
    )
  }

  private func temporaryDirectory() throws -> URL {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    addTeardownBlock { try? FileManager.default.removeItem(at: url) }
    return url
  }
}

private struct SimulatedFailure: Error {}
