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

  private func temporaryDirectory() throws -> URL {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    addTeardownBlock { try? FileManager.default.removeItem(at: url) }
    return url
  }
}
