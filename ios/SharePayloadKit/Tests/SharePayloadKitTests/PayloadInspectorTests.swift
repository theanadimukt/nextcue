import XCTest

@testable import SharePayloadKit

final class PayloadInspectorTests: XCTestCase {
  func testHTTPURLProducesContentFreeAcceptedEvidence() {
    let evidence = PayloadInspector.inspect(
      url: URL(string: "https://www.instagram.com/reel/example/?utm_source=share")!,
      receivedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )

    XCTAssertTrue(evidence.accepted)
    XCTAssertEqual(evidence.sourceType, .url)
    XCTAssertEqual(evidence.urlCount, 1)
    XCTAssertEqual(evidence.hostCategory, .instagram)
    XCTAssertFalse(evidence.propertyList.description.contains("example"))
  }

  func testPlainTextRecordsShapeWithoutContent() {
    let evidence = PayloadInspector.inspect(
      text: "Watch https://example.com/a and https://instagram.com/reel/b",
      receivedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )

    XCTAssertTrue(evidence.accepted)
    XCTAssertEqual(evidence.sourceType, .text)
    XCTAssertEqual(evidence.urlCount, 2)
    XCTAssertEqual(evidence.hostCategory, .instagram)
    XCTAssertEqual(evidence.characterCount, 60)
    XCTAssertFalse(evidence.propertyList.description.contains("Watch"))
    XCTAssertFalse(evidence.propertyList.description.contains("example.com"))
  }

  func testUnsupportedSchemeIsRejected() {
    let evidence = PayloadInspector.inspect(
      url: URL(string: "file:///private/test.txt")!,
      receivedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )

    XCTAssertFalse(evidence.accepted)
    XCTAssertEqual(evidence.rejectionReason, .unsupportedScheme)
    XCTAssertEqual(evidence.urlCount, 0)
  }

  func testOversizedTextIsRejectedBeforeURLInspection() {
    let evidence = PayloadInspector.inspect(
      text: String(repeating: "a", count: PayloadInspector.maximumTextLength + 1),
      receivedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )

    XCTAssertFalse(evidence.accepted)
    XCTAssertEqual(evidence.rejectionReason, .textTooLarge)
    XCTAssertEqual(evidence.characterCount, PayloadInspector.maximumTextLength + 1)
    XCTAssertEqual(evidence.urlCount, 0)
  }

  func testTextWithoutHTTPURLIsRejected() {
    let evidence = PayloadInspector.inspect(
      text: "ordinary text without a supported URL",
      receivedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )

    XCTAssertFalse(evidence.accepted)
    XCTAssertEqual(evidence.rejectionReason, .noHTTPURL)
  }

  func testUnsupportedRepresentationProducesContentFreeEvidence() {
    let evidence = PayloadInspector.unsupported(
      receivedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )

    XCTAssertFalse(evidence.accepted)
    XCTAssertEqual(evidence.sourceType, .unsupported)
    XCTAssertEqual(evidence.rejectionReason, .unsupportedType)
    XCTAssertEqual(evidence.characterCount, 0)
    XCTAssertEqual(evidence.urlCount, 0)
  }
}
