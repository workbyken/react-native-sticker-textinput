import * as React from 'react';
import {
  requireNativeComponent,
  NativeModules,
  findNodeHandle,
  Platform,
  ViewStyle,
} from 'react-native';

type StickerEvt = { nativeEvent: { png: string; adaptive?: boolean } };
type EmojiEvt   = { nativeEvent: { text: string } };

type Props = {
  style?: ViewStyle;
  placeholder?: string;
  text?: string;
  placeholderColor?: string;
  textColor?: string;
  fontSize?: number;
  fontFamily?: string;
  textAlign?: 'left' | 'center' | 'right' | 'justified' | 'natural' | string;
  paddingTop?: number;
  paddingLeft?: number;
  paddingBottom?: number;
  paddingRight?: number;
  editable?: boolean;
  onEmoji?: (e: EmojiEvt) => void;
  onSticker?: (e: StickerEvt) => void;
};

const NativeStickerInput = requireNativeComponent<Props>('StickerTextInput');
const NativeAPI = NativeModules.StickerTextInputManager as {
  focus: (reactTag: number) => void;
  blurInput: (reactTag: number) => void;
};

export const StickerTextInput = React.forwardRef<any, Props>((props, ref) => {
  const innerRef = React.useRef<any>(null);

  React.useImperativeHandle(ref, () => ({
    focus: () => {
      if (Platform.OS !== 'ios') return;
      const tag = findNodeHandle(innerRef.current);
      if (tag != null) NativeAPI.focus(tag);
    },
    blur: () => {
      if (Platform.OS !== 'ios') return;
      const tag = findNodeHandle(innerRef.current);
      if (tag != null) NativeAPI.blurInput(tag);
    },
  }));

  return <NativeStickerInput ref={innerRef} {...props} />;
});
