# Style Transfer機能 - トラブルシューティングガイド

## 問題: Style編集が"Failed"になる

Style Transfer機能でエラーが発生する場合、以下の原因が考えられます。

### 1. モデルファイルの問題

#### 確認方法
```
assets/models/style_transfer_quant.tflite
```
このファイルが存在し、サイズが2MB以上あることを確認してください。

#### 解決方法
正しいMagenta Arbitrary Style Transfer Int8モデルをダウンロード：
```bash
cd assets/models
curl -L "https://tfhub.dev/google/lite-model/magenta/arbitrary-image-stylization-v1-256/int8/prediction/1?lite-format=tflite" -o style_transfer_quant.tflite
```

### 2. モデルの入出力仕様が異なる

#### 症状
アプリのデバッグログに以下のようなエラーが表示される：
- "Input tensor index out of range"
- "Shape mismatch"
- "Cannot copy from a tensor with X elements to a tensor with Y elements"

#### 確認方法
アプリを実行してデバッグログを確認：
```bash
flutter run
```

ログで以下の情報を確認：
```
=== Style Transfer Initialization ===
Number of inputs: 2
  Input 0: [1, 384, 384, 3] TfLiteType.float32
  Input 1: [1, 256, 256, 3] TfLiteType.float32
Number of outputs: 1
  Output 0: [1, 384, 384, 3] TfLiteType.float32
```

#### 期待される仕様
現在のコードは以下の仕様に対応しています：
- **入力0（コンテンツ）**: `[1, 384, 384, 3]` float32
- **入力1（スタイル）**: `[1, 256, 256, 3]` float32
- **出力**: `[1, 384, 384, 3]` float32

#### 解決方法A: モデルを正しいものに交換
上記の仕様に合うモデルを使用してください（Magenta Arbitrary Style Transfer Int8 Prediction model）。

#### 解決方法B: コードを調整
モデルの仕様が異なる場合、`lib/services/style_transfer_service.dart`の定数を変更：

```dart
// 例: 入力サイズが256x256の場合
static const int _contentSize = 256;  // 変更
static const int _styleSize = 256;    // 変更
```

### 3. GPU Delegateの問題

#### 症状
- 処理が異常に遅い
- 推論時にクラッシュする

#### 解決方法
GPU Delegateを無効化する場合、`lib/services/style_transfer_service.dart`を編集：

```dart
// initialize()メソッド内のGPU delegateの部分をコメントアウト
/*
try {
  interpreterOptions.addDelegate(GpuDelegateV2());
  debugPrint('GPU delegate enabled');
} catch (e) {
  debugPrint('GPU delegate not available, using CPU: $e');
}
*/
```

### 4. スタイル画像が見つからない

#### 確認方法
以下のファイルが存在することを確認：
```
assets/styles/wave.jpg
assets/styles/rain_princess.jpg
assets/styles/la_muse.jpg
```

#### 解決方法
スタイル画像を追加またはダウンロードしてください。

### 5. メモリ不足

#### 症状
- 大きな画像で処理が失敗する
- "Out of memory"エラー

#### 解決方法
入力画像のサイズを制限するか、モデルの入力サイズを小さくする。

### 6. Int8量子化モデルの問題

#### 注意
Int8量子化モデルは入力の正規化方法が異なる場合があります。

#### 確認が必要な点
- 入力範囲: 0-255（uint8）か0.0-1.0（float32）か
- 出力範囲: 0-255（uint8）か0.0-1.0（float32）か

#### デバッグ方法
モデルの型を確認：
```
Input 0: [...] TfLiteType.uint8  ← uint8の場合
Input 0: [...] TfLiteType.float32  ← float32の場合
```

Uint8の場合、前処理を変更：
```dart
// _preprocessContentImage()内
// Float32Listの代わりにUint8Listを使用
inputBuffer[pixelIndex++] = pixel.r.toInt();  // 正規化しない
```

## よくある解決手順

### 手順1: クリーンビルド
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### 手順2: デバッグログを確認
```bash
flutter run
```
アプリでStyleタブのボタンを押して、ログを確認。

### 手順3: モデルを再ダウンロード
```bash
cd assets/models
rm style_transfer_quant.tflite
curl -L "https://tfhub.dev/google/lite-model/magenta/arbitrary-image-stylization-v1-256/int8/prediction/1?lite-format=tflite" -o style_transfer_quant.tflite
```

### 手順4: アセットを再確認
`pubspec.yaml`に以下が含まれていることを確認：
```yaml
assets:
  - assets/models/
  - assets/styles/
```

## 詳細なデバッグ方法

### ログの見方
正常な場合のログ例：
```
=== Style Transfer Initialization ===
Loading TFLite model from: models/style_transfer_quant.tflite
GPU delegate enabled
TFLite model loaded successfully
Number of inputs: 2
  Input 0: [1, 384, 384, 3] TfLiteType.float32
  Input 1: [1, 256, 256, 3] TfLiteType.float32
Number of outputs: 1
  Output 0: [1, 384, 384, 3] TfLiteType.float32
=== Initialization Complete ===

=== Running Inference ===
Content input size: 442368
Style input size: 196608
Expected content: 442368
Expected style: 196608
Starting TFLite inference...
Inference completed successfully
Output flattened successfully
=== Inference Complete ===
```

エラーの場合のログ例：
```
=== Error loading TFLite model ===
Error: Unable to open file: models/style_transfer_quant.tflite
```

## サポートが必要な場合

エラーログと以下の情報を提供してください：
1. デバッグログ全文（上記の===で囲まれた部分）
2. 使用しているモデルファイルのサイズ
3. テストに使用した画像のサイズ
4. デバイスの種類（Android/iOS、機種名）

## 参考リンク

- [TensorFlow Hub - Style Transfer Models](https://tfhub.dev/s?module-type=image-style-transfer)
- [Magenta Arbitrary Style Transfer](https://tfhub.dev/google/lite-model/magenta/arbitrary-image-stylization-v1-256/int8/prediction/1)
- [TFLite Flutter Package](https://pub.dev/packages/tflite_flutter)
