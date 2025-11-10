import * as React from 'react';
import { View, SafeAreaView, StyleSheet } from 'react-native';
import { GiftedChat } from 'react-native-gifted-chat';
import { StickerTextInput } from 'react-native-sticker-textinput';

// Single-input composer replacement using StickerTextInput
const StickerComposer = React.memo((props: any) => {
  const {
    text,
    onTextChanged,
    onInputSizeChanged,
    composerHeight,
    placeholder,
    textInputStyle,
    textInputProps,
    __onSticker,
  } = props;

  const stickerRef = React.useRef<any>(null);

  const onLayout = React.useCallback((e: any) => {
    const { width, height } = e?.nativeEvent?.layout || {};
    if (width != null && height != null) onInputSizeChanged?.({ width, height });
  }, [onInputSizeChanged]);

  const baseStyle = {
    flex: 1,
    padding: 8,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#ddd',
    backgroundColor: 'white',
    minHeight: composerHeight ?? 36,
  } as const;
  const flattened = (StyleSheet.flatten(textInputStyle) as any) || {};

  return (
    <View style={{ flex: 1, justifyContent: 'center' }} onLayout={onLayout}>
      <StickerTextInput
        ref={(node: any) => {
          stickerRef.current = node;
          if (!node) return;
          const native = node;
          const extended = native as any;
          extended.clear = () => {
            try { native.setNativeProps?.({ text: '' }); } catch {}
            onTextChanged?.('');
          };
          extended.focus = () => { try { native.focus?.(); } catch {} };
          extended.blur  = () => { try { native.blur?.(); } catch {} };
          extended.isFocused = () => false;

          const extRef = textInputProps?.ref;
          if (extRef) {
            if (typeof extRef === 'function') extRef(extended);
            else if (typeof extRef === 'object') (extRef as any).current = extended;
          }
        }}
        placeholder={placeholder}
        // Pass controlled value if available (types may lag locally)
        {...({ text } as any)}
        onEmoji={(e: any) => onTextChanged?.(e.nativeEvent.text)}
        onSticker={(e: any) => __onSticker?.(e)}
        style={{ ...baseStyle, ...flattened }}
      />
    </View>
  );
});

export default function App() {
  const [messages, setMessages] = React.useState<any[]>([]);
  const [text, setText] = React.useState('');
  const user = { _id: 1, name: 'You' };

  const handleSend = React.useCallback((newMessages: any[] = []) => {
    setMessages(prev => GiftedChat.append(prev, newMessages));
    // Ensure input is cleared in controlled mode
    setText('');
  }, []);

  const onSendSticker = React.useCallback((uri: string) => {
    setMessages(prev =>
      GiftedChat.append(prev, [
        { _id: Date.now(), createdAt: new Date(), user, image: uri },
      ])
    );
  }, []);

  const renderComposer = React.useCallback((composerProps: any) => (
    <StickerComposer
      {...composerProps}
      __onSticker={(e: any) => onSendSticker(`data:image/png;base64,${e.nativeEvent.png}`)}
    />
  ), [onSendSticker]);

  return (
    <SafeAreaView style={styles.container}>
      <GiftedChat
        messages={messages}
        onSend={handleSend}
        text={text}
        onInputTextChanged={setText}
        user={user}
        alwaysShowSend
        keyboardShouldPersistTaps="handled"
        renderComposer={renderComposer}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fafafa' },
});
