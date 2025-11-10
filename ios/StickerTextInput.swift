import UIKit
import React

@objc(StickerTextInput)
class StickerTextInput: UITextView {

  // JS events
  @objc var onEmoji: RCTDirectEventBlock?
  @objc var onSticker: RCTDirectEventBlock?
  @objc var onFocus: RCTDirectEventBlock?
  @objc var onBlur: RCTDirectEventBlock?

  // Optional placeholder
  @objc var placeholder: NSString? {
    didSet { setNeedsDisplay() }
  }

  // Customization props (set from React Native)
  @objc var placeholderColor: UIColor? { didSet { setNeedsDisplay() } }
  @objc var fontSize: NSNumber? { didSet { updateFont() } }
  @objc var fontFamily: NSString? { didSet { updateFont() } }
  @objc var textAlign: NSString? { didSet { updateAlignment() } }
  @objc var paddingTop: NSNumber? { didSet { updateInsets() } }
  @objc var paddingLeft: NSNumber? { didSet { updateInsets() } }
  @objc var paddingBottom: NSNumber? { didSet { updateInsets() } }
  @objc var paddingRight: NSNumber? { didSet { updateInsets() } }

  // Track programmatic updates coming from JS 'text' prop to avoid firing delegate
  private var isUpdatingFromJS: Bool = false

  // Make the view controlled by React Native via 'text' prop
  override var text: String! {
    willSet { isUpdatingFromJS = true }
    didSet {
      isUpdatingFromJS = false
      setNeedsDisplay()
    }
  }

  // MARK: - Init
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  private func commonInit() {
    isScrollEnabled = true
    backgroundColor = .clear
    font = UIFont.preferredFont(forTextStyle: .body)
    textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    // Critical: accept attributed text + attachments
    allowsEditingTextAttributes = true

    // iOS 18+ — enable adaptive image glyphs (new sticker/memoji path)
    if #available(iOS 18.0, *) {
      self.supportsAdaptiveImageGlyph = true
    }

    // Keyboard behaviors you likely want
    autocapitalizationType = .sentences
    autocorrectionType = .default
    smartInsertDeleteType = .yes
    dataDetectorTypes = []

    // Observe editing and text changes instead of using delegate to avoid
    // conflicts with react-native-keyboard-controller's composite delegate
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(handleTextDidChange(_:)),
                                           name: UITextView.textDidChangeNotification,
                                           object: self)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(handleDidBeginEditing(_:)),
                                           name: UITextView.textDidBeginEditingNotification,
                                           object: self)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(handleDidEndEditing(_:)),
                                           name: UITextView.textDidEndEditingNotification,
                                           object: self)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  private func updateFont() {
    let size = CGFloat(fontSize?.doubleValue ?? Double(UIFont.preferredFont(forTextStyle: .body).pointSize))
    if let family = fontFamily as String?, let custom = UIFont(name: family, size: size) {
      font = custom
    } else {
      font = UIFont.systemFont(ofSize: size)
    }
    setNeedsDisplay()
  }

  private func updateInsets() {
    let current = textContainerInset
    let top = paddingTop?.doubleValue != nil ? CGFloat(truncating: paddingTop!) : current.top
    let left = paddingLeft?.doubleValue != nil ? CGFloat(truncating: paddingLeft!) : current.left
    let bottom = paddingBottom?.doubleValue != nil ? CGFloat(truncating: paddingBottom!) : current.bottom
    let right = paddingRight?.doubleValue != nil ? CGFloat(truncating: paddingRight!) : current.right
    textContainerInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    setNeedsLayout()
    setNeedsDisplay()
  }

  private func updateAlignment() {
    switch (textAlign as String?)?.lowercased() {
    case "center": textAlignment = .center
    case "right": textAlignment = .right
    case "justified": textAlignment = .justified
    case "natural": textAlignment = .natural
    default: textAlignment = .left
    }
  }

  // MARK: - Notification handlers
  @objc private func handleTextDidChange(_ note: Notification) {
    if isUpdatingFromJS { return }
    // 1) Try adaptive glyphs (iOS 18)
    if #available(iOS 18.0, *) {
      if let png = extractAdaptiveGlyphPNG(from: attributedText) {
        onSticker?( ["png": png.base64EncodedString(), "adaptive": true] )
        attributedText = NSAttributedString(string: "")
        setNeedsDisplay()
        return
      }
    }

    // 2) Fallback: classic attachments (iOS 17/earlier)
    if let png = extractAttachmentPNG(from: attributedText) {
      onSticker?( ["png": png.base64EncodedString(), "adaptive": false] )
      attributedText = NSAttributedString(string: "")
      setNeedsDisplay()
      return
    }

    // 3) Plain text / emoji (Unicode) path — emit but do NOT clear to keep it visible.
    if let t = text, !t.isEmpty {
      onEmoji?( ["text": t] )
    }

    // Ensure placeholder visibility is updated when text changes
    setNeedsDisplay()
  }

  @objc private func handleDidBeginEditing(_ note: Notification) {
    onFocus?( [:] )
  }

  @objc private func handleDidEndEditing(_ note: Notification) {
    onBlur?( [:] )
  }

  // MARK: - Extraction helpers
  @available(iOS 18.0, *)
  private func extractAdaptiveGlyphPNG(from attr: NSAttributedString?) -> Data? {
    guard let attr else { return nil }
    var data: Data?
    attr.enumerateAttribute(.adaptiveImageGlyph,
                            in: NSRange(location: 0, length: attr.length)) { value, _, stop in
      if let glyph = value as? NSAdaptiveImageGlyph {
        data = glyph.imageContent
        stop.pointee = true
      }
    }
    return data
  }

  private func extractAttachmentPNG(from attr: NSAttributedString?) -> Data? {
    guard let attr else { return nil }
    var png: Data?
    attr.enumerateAttribute(.attachment,
                            in: NSRange(location: 0, length: attr.length)) { value, _, stop in
      guard let a = value as? NSTextAttachment else { return }
      // In-memory image
      if let img = a.image ?? a.image(forBounds: a.bounds, textContainer: nil, characterIndex: 0),
         let d = img.pngData() {
        png = d
        stop.pointee = true
        return
      }
      // File-backed attachment
      if let d = a.fileWrapper?.regularFileContents {
        png = d
        stop.pointee = true
      }
    }
    return png
  }

  // MARK: - Placeholder
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard !hasText, let ph = placeholder as String?, !ph.isEmpty else { return }
    let attrs: [NSAttributedString.Key: Any] = [
      .foregroundColor: (placeholderColor ?? UIColor.secondaryLabel),
      .font: font ?? UIFont.preferredFont(forTextStyle: .body)
    ]
    (ph as NSString).draw(in: rect.insetBy(dx: 12, dy: 8), withAttributes: attrs)
  }
}
