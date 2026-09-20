import XCTest

@testable import SharePayloadKit

final class PayloadInspectorTests: XCTestCase {
  func testHTTPURLProducesContentFreeSupportedRepresentationEvidence() {
    let evidence = PayloadInspector.inspect(
      url: URL(string: "https://www.instagram.com/reel/example/?utm_source=share")!,
      receivedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )

    XCTAssertTrue(evidence.representationSupported)
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

    XCTAssertTrue(evidence.representationSupported)
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

    XCTAssertFalse(evidence.representationSupported)
    XCTAssertEqual(evidence.rejectionReason, .unsupportedScheme)
    XCTAssertEqual(evidence.urlCount, 0)
  }

  func testOversizedTextIsRejectedBeforeURLInspection() {
    let evidence = PayloadInspector.inspect(
      text: String(repeating: "a", count: PayloadInspector.maximumTextLength + 1),
      receivedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )

    XCTAssertFalse(evidence.representationSupported)
    XCTAssertEqual(evidence.rejectionReason, .textTooLarge)
    XCTAssertEqual(evidence.characterCount, PayloadInspector.maximumTextLength + 1)
    XCTAssertEqual(evidence.urlCount, 0)
  }

  func testTextWithoutHTTPURLIsRejected() {
    let evidence = PayloadInspector.inspect(
      text: "ordinary text without a supported URL",
      receivedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )

    XCTAssertFalse(evidence.representationSupported)
    XCTAssertEqual(evidence.rejectionReason, .noHTTPURL)
  }

  func testUnsupportedRepresentationProducesContentFreeEvidence() {
    let evidence = PayloadInspector.unsupported(
      receivedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )

    XCTAssertFalse(evidence.representationSupported)
    XCTAssertEqual(evidence.sourceType, .unsupported)
    XCTAssertEqual(evidence.rejectionReason, .unsupportedType)
    XCTAssertEqual(evidence.characterCount, 0)
    XCTAssertEqual(evidence.urlCount, 0)
  }

  func testSelectionPrefersAValidLaterRepresentation() {
    let rejected = PayloadInspector.inspect(text: "not a URL")
    let supported = PayloadInspector.inspect(
      url: URL(string: "https://instagram.com/reel/example")!)

    XCTAssertEqual(EvidenceSelector.select([rejected, supported]), supported)
  }

  func testSelectionPreservesFirstSpecificRejectionWhenNoneAreSupported() {
    let rejectedText = PayloadInspector.inspect(text: "not a URL")
    let unsupported = PayloadInspector.unsupported()

    XCTAssertEqual(EvidenceSelector.select([rejectedText, unsupported]), rejectedText)
  }

  func testCandidateExtractionKeepsOnlyFirstFourHTTPURLs() {
    let urls = PayloadInspector.candidateHTTPURLs(
      in: "https://a.example/1 file:///private/a https://b.example/2 "
        + "https://c.example/3 https://d.example/4 https://e.example/5"
    )

    XCTAssertEqual(
      urls.map(\.absoluteString),
      [
        "https://a.example/1",
        "https://b.example/2",
        "https://c.example/3",
        "https://d.example/4",
      ]
    )
  }
}
