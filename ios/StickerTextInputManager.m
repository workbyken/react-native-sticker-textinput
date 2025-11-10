#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(StickerTextInputManager, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(onEmoji, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onSticker, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(placeholder, NSString)
RCT_EXPORT_VIEW_PROPERTY(text, NSString)
// Styling / behavior props
RCT_EXPORT_VIEW_PROPERTY(placeholderColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(textColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(fontSize, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(fontFamily, NSString)
RCT_EXPORT_VIEW_PROPERTY(textAlign, NSString)
RCT_EXPORT_VIEW_PROPERTY(paddingTop, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(paddingLeft, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(paddingBottom, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(paddingRight, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(editable, BOOL)

// Imperative commands
RCT_EXTERN_METHOD(focus:(nonnull NSNumber *)reactTag)
RCT_EXTERN_METHOD(blurInput:(nonnull NSNumber *)reactTag)
@end
