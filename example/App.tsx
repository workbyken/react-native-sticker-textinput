import * as React from 'react';
import { View, Text, Image, SafeAreaView, StyleSheet } from 'react-native';
import { StickerTextInput } from 'react-native-sticker-textinput';

export default function App() {
  const [log, setLog] = React.useState<string>('waiting…');
  const [img, setImg] = React.useState<string | null>(null);

  // Temporary: use an `any` prop bag so example compiles even if local package types
  // haven't refreshed yet. The native side supports these props.
  const inputAppearance: any = {
    placeholderColor: '#9AA0A6',
    textColor: '#111111',
    fontSize: 16,
    textAlign: 'left',
    paddingTop: 8,
    paddingLeft: 12,
    paddingBottom: 8,
    paddingRight: 12,
    editable: true,
  };

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.header}>Sticker Input Test</Text>

      <StickerTextInput
        placeholder="Type emoji or insert a sticker…"
        {...inputAppearance}
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
