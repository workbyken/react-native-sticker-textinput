import React

@objc(StickerTextInputManager)
class StickerTextInputManager: RCTViewManager {
  override static func requiresMainQueueSetup() -> Bool { true }

  override func view() -> UIView! {
    return StickerTextInput()
  }

  // Optional imperative methods (called from JS with reactTag)
  @objc func focus(_ reactTag: NSNumber) {
    bridge.uiManager.addUIBlock { _, registry in
      (registry?[reactTag] as? StickerTextInput)?.becomeFirstResponder()
    }
  }

  @objc func blurInput(_ reactTag: NSNumber) {
    bridge.uiManager.addUIBlock { _, registry in
      (registry?[reactTag] as? StickerTextInput)?.resignFirstResponder()
    }
  }
}
