import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
  private static let appGroupIdentifier = "group.app.nextcue.share-spike"
  private static let evidenceKey = "lastShareEvidence"
  private static let queueDirectoryName = "pending-handoffs"
  private static let maximumAttachmentCount = 4

  private let statusLabel = UILabel()
  private let doneButton = UIButton(type: .system)
  private var canCompleteRequest = false
  private var hasFinishedInspection = false

  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
    inspectInput()
  }

  private func configureView() {
    view.backgroundColor = .systemBackground
    statusLabel.text = "Inspecting shared content…"
    statusLabel.numberOfLines = 0
    statusLabel.textAlignment = .center
    statusLabel.accessibilityTraits = .staticText

    doneButton.setTitle("Done", for: .normal)
    doneButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    doneButton.isEnabled = false
    doneButton.addTarget(self, action: #selector(finish), for: .touchUpInside)

    let stack = UIStackView(arrangedSubviews: [statusLabel, doneButton])
    stack.axis = .vertical
    stack.alignment = .fill
    stack.spacing = 24
    stack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      doneButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
    ])
  }

  private func inspectInput() {
    guard
      let item = extensionContext?.inputItems.first as? NSExtensionItem,
      extensionContext?.inputItems.count == 1,
      item.attachments?.count ?? 0 <= Self.maximumAttachmentCount
    else {
      finishInspection(with: PayloadInspector.unsupported())
      return
    }

    var candidates: [ShareEvidence] = []
    if let text = item.attributedContentText?.string, !text.isEmpty {
      let receivedAt = Date()
      let evidence = PayloadInspector.inspect(text: text, receivedAt: receivedAt)
      if evidence.representationSupported {
        finishInspection(
          with: evidence,
          envelope: try? SharedCaptureEnvelope(
            receivedAt: receivedAt,
            sourceHint: .text,
            rawText: text,
            candidateURLs: PayloadInspector.candidateHTTPURLs(in: text).map(\.absoluteString)
          )
        )
        return
      }
      candidates.append(evidence)
    }
    inspect(providers: item.attachments ?? [], at: 0, candidates: candidates)
  }

  private func inspect(
    providers: [NSItemProvider],
    at index: Int,
    candidates: [ShareEvidence]
  ) {
    guard index < providers.count else {
      finishInspection(with: EvidenceSelector.select(candidates))
      return
    }

    let provider = providers[index]
    if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
      provider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] value, _ in
        guard let self else { return }
        let url = value as? URL ?? (value as? NSURL).map { $0 as URL }
        DispatchQueue.main.async {
          if let url {
            let receivedAt = Date()
            let evidence = PayloadInspector.inspect(url: url, receivedAt: receivedAt)
            if evidence.representationSupported {
              self.finishInspection(
                with: evidence,
                envelope: try? SharedCaptureEnvelope(
                  receivedAt: receivedAt,
                  sourceHint: .url,
                  rawText: nil,
                  candidateURLs: [url.absoluteString]
                )
              )
            } else {
              self.inspectText(
                from: provider,
                providers: providers,
                at: index,
                candidates: candidates + [evidence]
              )
            }
          } else {
            self.inspectText(
              from: provider,
              providers: providers,
              at: index,
              candidates: candidates
            )
          }
        }
      }
      return
    }

    inspectText(from: provider, providers: providers, at: index, candidates: candidates)
  }

  private func inspectText(
    from provider: NSItemProvider,
    providers: [NSItemProvider],
    at index: Int,
    candidates: [ShareEvidence]
  ) {
    if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
      provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { [weak self] value, _ in
        guard let self else { return }
        let text = value as? String ?? (value as? NSString).map(String.init)
        DispatchQueue.main.async {
          if let text {
            let receivedAt = Date()
            let evidence = PayloadInspector.inspect(text: text, receivedAt: receivedAt)
            if evidence.representationSupported {
              self.finishInspection(
                with: evidence,
                envelope: try? SharedCaptureEnvelope(
                  receivedAt: receivedAt,
                  sourceHint: .text,
                  rawText: text,
                  candidateURLs: PayloadInspector.candidateHTTPURLs(in: text).map(\.absoluteString)
                )
              )
            } else {
              self.inspect(
                providers: providers,
                at: index + 1,
                candidates: candidates + [evidence]
              )
            }
          } else {
            self.inspect(providers: providers, at: index + 1, candidates: candidates)
          }
        }
      }
      return
    }

    inspect(providers: providers, at: index + 1, candidates: candidates)
  }

  private func finishInspection(
    with evidence: ShareEvidence,
    envelope: SharedCaptureEnvelope? = nil
  ) {
    guard !hasFinishedInspection else { return }
    hasFinishedInspection = true
    UserDefaults(suiteName: Self.appGroupIdentifier)?.set(
      evidence.propertyList,
      forKey: Self.evidenceKey
    )

    if evidence.representationSupported {
      guard let envelope,
        let container = FileManager.default.containerURL(
          forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier
        )
      else {
        statusLabel.text = "Unable to access shared storage. Nothing was saved."
        doneButton.isEnabled = true
        return
      }
      do {
        try HandoffQueue(
          directoryURL: container.appendingPathComponent(Self.queueDirectoryName)
        ).enqueue(envelope)
        canCompleteRequest = true
        statusLabel.text = "Saved for import."
      } catch {
        statusLabel.text = "Unable to save shared content. Please try again."
      }
    } else {
      statusLabel.text = "Unsupported share. No shared content was recorded."
    }
    doneButton.isEnabled = true
  }

  @objc private func finish() {
    if canCompleteRequest {
      extensionContext?.completeRequest(returningItems: nil)
    } else {
      extensionContext?.cancelRequest(
        withError: NSError(
          domain: "app.nextcue.share-extension",
          code: 1,
          userInfo: [NSLocalizedDescriptionKey: "Unsupported share input"]
        )
      )
    }
  }
}
