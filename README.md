# react-native-sticker-textinput

A tiny iOS-only `UITextView` bridge for React Native that captures Apple emoji and iOS stickers (including iOS 18 adaptive image glyphs) and sends them to JS as events. It behaves like a text input and lets you fully style the native field (font, color, alignment, paddings, placeholder color, editability), while emitting:

- `onEmoji`: plain text and emoji characters (Unicode) you type
- `onSticker`: PNG payloads for iOS stickers/memoji (iOS 17 attachments and iOS 18 adaptive glyphs)

This makes it easy to build experiences like “attach a sticker as an image bubble” and “type emoji inline” — and to integrate with chat UIs such as GiftedChat.

> Platform: iOS only. The native view class is `StickerTextInput`.

## Requirements

- React Native >= 0.74
- React >= 18
- iOS 17+ (iOS 18 enables the new adaptive image glyph path)

## Installation

Install from your registry (or use a local `file:` link while developing):

```bash
# Typical install (adjust to your package name/version)
npm install react-native-sticker-textinput

# or when working from this repo locally (as used by the example):
# in example/package.json → "react-native-sticker-textinput": "file:.."
```

iOS pods:

```bash
npx pod-install
```

If you use Reanimated in your app, ensure the plugin is added in `babel.config.js` (the example has this already).

## Usage (Simple Example)

The simplest setup renders the input and listens for events. See `example/App.tsx`.

```tsx
import * as React from 'react';
import { View, Text, Image, SafeAreaView, StyleSheet } from 'react-native';
import { StickerTextInput } from 'react-native-sticker-textinput';

export default function App() {
  const [log, setLog] = React.useState('waiting…');
  const [img, setImg] = React.useState<string | null>(null);

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.header}>Sticker Input Test</Text>

      <StickerTextInput
        placeholder="Type emoji or insert a sticker…"
        placeholderColor="#9AA0A6"
        textColor="#111111"
        fontSize={16}
        textAlign="left"
        paddingTop={8}
        paddingLeft={12}
        paddingBottom={8}
        paddingRight={12}
        editable
        onEmoji={(e) => {
          setLog(`Emoji: ${e.nativeEvent.text}`);
        }}
        onSticker={(e) => {
          const base64 = e.nativeEvent.png;
          const uri = `data:image/png;base64,${base64}`;
          setImg(uri);
          setLog(`Sticker received (${base64.length}b)`);
        }}
        style={styles.input}
      />

      <Text style={styles.log}>{log}</Text>
      {img && <Image source={{ uri: img }} style={styles.preview} />}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, backgroundColor: '#fafafa' },
  header: { fontSize: 18, fontWeight: '600', marginBottom: 16 },
  input: {
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 10,
    minHeight: 50,
    padding: 8,
    backgroundColor: 'white',
  },
  log: { marginTop: 16, fontSize: 14, color: '#555' },
  preview: { width: 120, height: 120, marginTop: 16, borderRadius: 8, backgroundColor: '#eee' },
});
```

## Props

The component exposes a set of view-level and text-level props, plus events.

```ts
export type StickerTextInputProps = {
  // View-level styling
  style?: ViewStyle; // borders, background, radius, etc.

  // Optional placeholder
  placeholder?: string;
  placeholderColor?: string; // color for the placeholder text

  // Text styling / behavior
  text?: string;             // optional controlled value (iOS only)
  textColor?: string;        // content text color
  fontSize?: number;         // content font size
  fontFamily?: string;       // content font family
  textAlign?: 'left' | 'center' | 'right' | 'justified' | 'natural';
  paddingTop?: number;
  paddingLeft?: number;
  paddingBottom?: number;
  paddingRight?: number;
  editable?: boolean;        // default true

  // Events
  onEmoji?: (e: { nativeEvent: { text: string } }) => void;
  onSticker?: (e: { nativeEvent: { png: string; adaptive?: boolean } }) => void;
}
```

### Imperative methods (ref)

`StickerTextInput` supports `focus()` and `blur()` via a forwarded ref (iOS only):

```tsx
const ref = React.useRef<any>(null);

<StickerTextInput ref={ref} />

// later
ref.current?.focus();
ref.current?.blur();
```

## Behavior Notes

- On iOS 18+, Apple introduced adaptive image glyphs. The component detects them and emits `onSticker` with `{png, adaptive: true}`.
- On iOS 17 and earlier, it falls back to scanning text attachments and emits `onSticker` with `{png, adaptive: false}`.
- Plain text and emoji characters are emitted via `onEmoji` and are no longer cleared by the native view; the input remains visible and behaves like a standard text input.
- Placeholder is custom-drawn and hides automatically whenever there is content.

## GiftedChat Integration (Two Approaches)

GiftedChat expects a real `TextInput` ref to manage focus/clear logic. There are two patterns you can use:

### 1) Minimal integration (recommended to start)

Keep GiftedChat’s default composer for text, and use `StickerTextInput` elsewhere in your UI (e.g., accessory) to send stickers as image messages. This avoids any focus/ref complexity.

```tsx
// Pseudocode inside your chat screen
const onSticker = (pngBase64: string) => {
  onSend([{ image: `data:image/png;base64,${pngBase64}` }]);
};

// Render StickerTextInput above/below the toolbar as you prefer
```

### 2) Advanced: Custom composer replacement (experimental)

If you want `StickerTextInput` to be the composer, ensure GiftedChat still gets a `TextInput` ref it can use.

A pattern that works is to render:

- A hidden native `TextInput` wired to `props.textInputProps.ref` (so GC can call `clear()/focus()/isFocused()` safely), and
- The visible `StickerTextInput` which updates GC’s text via `onEmoji` and sends images via `onSticker`.

This is sensitive to library versions and your app’s keyboard handling; start from the minimal approach first.

## Example App

The `example/` folder demonstrates a minimal setup using a local `file:..` link to this package.

Run it on iOS:

```bash
cd example
npm install
npx pod-install
npx react-native start --reset-cache
npm run ios
```

The example shows:

- Typing emoji/letters updates the log
- Inserting a sticker displays a preview image

## Troubleshooting

- Placeholder shows behind text
  - Ensure you rebuilt after pulling the latest native changes. The placeholder hides using `hasText` and redraws on updates.

- TypeScript props aren’t recognized (e.g., `placeholderColor`)
  - If you use a local `file:..` link, restart Metro with `--reset-cache` and reload your editor’s TypeScript server.

- GiftedChat hard-crashes when using a custom composer
  - Keep the default composer first (Approach 1). If you replace it, be sure to pass a valid `TextInput` ref for GiftedChat internals.

## License

MIT
