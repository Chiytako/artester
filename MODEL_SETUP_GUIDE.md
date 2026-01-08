# Style Transfer Model Setup Guide

## 問題: 現在のモデルについて

ダウンロードしたMagenta Arbitrary Style Transferモデルは、**2つの入力**が必要です：
1. コンテンツ画像（変換したい写真）
2. スタイル画像（芸術作品など）

しかし、現在の実装は**単一入力のみ**をサポートしています。

## 解決策

以下のいずれかの方法を選択してください：

### オプション1: 単一入力モデルを使用（推奨）

事前学習済みの固定スタイルモデルを使用します。これらは1つの入力のみで動作します。

#### モデルの入手方法

1. **TensorFlow Hub で検索**:
   https://tfhub.dev/s?q=style%20transfer

2. **推奨モデル**:
   - Fast Style Transfer models (固定スタイル)
   - 入力: [1, H, W, 3] (単一画像)
   - 出力: [1, H, W, 3] (スタイル変換された画像)

3. **カスタムモデルを作成**:
   - TensorFlowでStyle Transferモデルを学習
   - 単一スタイルで学習（例: Van Gogh風）
   - TFLite形式で変換

### オプション2: コードを修正して2入力モデルを使用

Magentaモデルを使用するには、`style_transfer_service.dart`を修正して、スタイル画像も渡す必要があります。

#### 必要な修正:

1. **スタイル画像をアセットに追加**:
   ```
   assets/styles/
   ├── vangogh_starry_night.jpg
   ├── monet_impression.jpg
   └── picasso_abstract.jpg
   ```

2. **`_runInference`メソッドを修正**:
   ```dart
   Float32List _runInference(Float32List contentInput, Float32List styleInput) {
     // 入力を2つ準備
     final inputs = {
       0: contentInput.reshape([1, 384, 384, 3]),  // コンテンツ
       1: styleInput.reshape([1, 256, 256, 3]),    // スタイル
     };

     // 出力バッファ
     final output = ...;

     // 推論実行
     _interpreter!.runForMultipleInputs(inputs, {0: output});

     return flattenOutput(output);
   }
   ```

3. **スタイル画像の読み込みロジックを追加**

## テスト用の簡単な解決策

開発・テスト目的で、ダミーモデルを作成することもできます：

### Pythonでダミーモデルを作成:

```python
import tensorflow as tf
import numpy as np

# 単純なパススルーモデル（画像をそのまま返す）
class StyleTransferModel(tf.Module):
    @tf.function(input_signature=[
        tf.TensorSpec(shape=[1, 384, 384, 3], dtype=tf.float32)
    ])
    def call(self, x):
        # 簡単なスタイル効果（例: 色調を変える）
        styled = x * 0.9 + 0.05  # 少し暗くして青みを加える
        return tf.clip_by_value(styled, 0.0, 1.0)

# モデルを保存
model = StyleTransferModel()
concrete_func = model.call.get_concrete_function()

# TFLiteに変換
converter = tf.lite.TFLiteConverter.from_concrete_functions([concrete_func])
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

# 保存
with open('style_transfer_quant.tflite', 'wb') as f:
    f.write(tflite_model)

print("モデル作成完了！")
```

### 実行方法:

```bash
cd assets/models
python create_dummy_model.py
```

## 実際の製品用モデル

製品として使用する場合は、以下のような高品質なモデルを推奨します：

1. **TensorFlow Lite Model Maker**で学習
   - https://www.tensorflow.org/lite/models/modify/model_maker/image_classification

2. **PyTorchで学習してONNX経由でTFLiteに変換**
   - Fast Neural Style Transfer
   - https://github.com/pytorch/examples/tree/master/fast_neural_style

3. **商用モデルを購入**
   - Runway ML
   - DeepAI

## 現在のステータス

✅ コードは完成 - 単一入力モデル用
✅ UI実装完了
⚠️ 互換性のあるモデルファイルが必要

## 次のステップ

1. **オプション1を選択する場合**:
   - 上記のPythonスクリプトでダミーモデルを作成
   - または、互換性のある単一入力モデルを見つける

2. **オプション2を選択する場合**:
   - コードを修正して2入力に対応
   - スタイル画像をアセットに追加

3. **すぐにテストしたい場合**:
   - ダミーモデルを作成（上記Pythonスクリプト使用）
   - 基本的な動作確認を実施

---

**推奨**: 今すぐテストしたい場合は、上記のPythonスクリプトを使用してダミーモデルを作成してください。これにより、UIと全体的な流れが正しく動作することを確認できます。
