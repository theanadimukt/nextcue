import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
  private static let appGroupIdentifier = "group.app.nextcue.share-spike"
  private static let evidenceKey = "lastShareEvidence"
  private static let maximumAttachmentCount = 4

  private let statusLabel = UILabel()
  private let doneButton = UIButton(type: .system)
  private var requestAccepted = false

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

    if let text = item.attributedContentText?.string, !text.isEmpty {
      let evidence = PayloadInspector.inspect(text: text)
      if evidence.accepted {
        finishInspection(with: evidence)
        return
      }
    }
    inspect(providers: item.attachments ?? [], at: 0)
  }

  private func inspect(providers: [NSItemProvider], at index: Int) {
    guard index < providers.count else {
      finishInspection(with: PayloadInspector.unsupported())
      return
    }

    let provider = providers[index]
    if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
      provider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] value, _ in
        guard let self else { return }
        let url = value as? URL ?? (value as? NSURL).map { $0 as URL }
        DispatchQueue.main.async {
          if let url {
            self.finishInspection(with: PayloadInspector.inspect(url: url))
          } else {
            self.inspect(providers: providers, at: index + 1)
          }
        }
      }
      return
    }

    if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
      provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { [weak self] value, _ in
        guard let self else { return }
        let text = value as? String ?? (value as? NSString).map(String.init)
        DispatchQueue.main.async {
          if let text {
            self.finishInspection(with: PayloadInspector.inspect(text: text))
          } else {
            self.inspect(providers: providers, at: index + 1)
          }
        }
      }
      return
    }

    inspect(providers: providers, at: index + 1)
  }

  private func finishInspection(with evidence: ShareEvidence) {
    requestAccepted = evidence.accepted
    UserDefaults(suiteName: Self.appGroupIdentifier)?.set(
      evidence.propertyList,
      forKey: Self.evidenceKey
    )
    statusLabel.text =
      evidence.accepted
      ? "Supported share received. Only structural evidence was recorded."
      : "Unsupported share. No shared content was recorded."
    doneButton.isEnabled = true
  }

  @objc private func finish() {
    if requestAccepted {
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
