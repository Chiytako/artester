# レイヤーシステム & マスク編集機能

## 概要

Artesterに本格的なレイヤーベースの画像編集システムとマスク編集機能を実装しました。Photoshop/GIMPのような、複数のレイヤーを管理・編集できるプロフェッショナルな画像編集アプリケーションへと進化しました。

## 主な機能

### 🎨 レイヤーシステム

- **複数レイヤー管理**: 最大20レイヤーまで対応
- **レイヤー操作**: 追加、削除、複製、並び替え
- **レイヤープロパティ**:
  - 不透明度調整（0-100%）
  - ブレンドモード（Normal、Multiply、Screen、Overlay等）
  - 表示/非表示切り替え
  - レイヤーロック
- **レイヤーごとの編集パラメータ**: 明度、コントラスト、彩度など独立して調整可能

### 🎭 マスク編集機能

- **レイヤーマスク**: 各レイヤーに個別のマスクを適用
- **マスク編集ツール**:
  - ブラシ（追加）
  - 消しゴム（削除）
  - グラデーション
- **ブラシ設定**:
  - サイズ調整（1-500px）
  - 硬さ調整（0-100%）
  - 不透明度調整（0-100%）
- **マスク操作**:
  - マスク反転
  - マスクの有効/無効切り替え
  - AI被写体抽出をマスクとして使用

### 🎬 ブレンドモード

以下のブレンドモードをサポート：
- Normal（通常）
- Multiply（乗算）
- Screen（スクリーン）
- Overlay（オーバーレイ）
- Soft Light（ソフトライト）
- Hard Light（ハードライト）
- Add（加算）
- Subtract（減算）
- Difference（差の絶対値）
- Darken（比較（暗））
- Lighten（比較（明））

## アーキテクチャ

### モデル層

#### Layer (`lib/models/layer.dart`)
各レイヤーの情報を保持：
- 画像データ
- レイヤーマスク
- 編集パラメータ
- 不透明度、ブレンドモード
- ジオメトリ変換（回転、反転）
- 表示状態、ロック状態

#### LayerMask (`lib/models/layer_mask.dart`)
マスク情報を保持：
- マスク画像（グレースケール）
- 有効/無効状態
- マスク不透明度
- マスク反転フラグ

#### LayerStack (`lib/models/layer_stack.dart`)
レイヤーの集合を管理：
- レイヤーリスト
- アクティブレイヤーID
- キャンバスサイズ
- バージョン管理（Undo/Redo用）

### Provider層

#### LayerStackProvider (`lib/providers/layer_stack_provider.dart`)
レイヤースタックの状態管理：
- レイヤーの追加・削除・複製
- レイヤーの並び替え
- アクティブレイヤーの管理
- レイヤープロパティの更新
- マスクの管理

#### MaskEditProvider (`lib/providers/mask_edit_provider.dart`)
マスク編集の状態管理：
- ツール選択（ブラシ、消しゴム、グラデーション）
- ブラシ設定（サイズ、硬さ、不透明度）
- マスク描画処理

### サービス層

#### LayerCompositor (`lib/services/layer_compositor.dart`)
レイヤー合成エンジン：
- 複数レイヤーの合成処理
- ブレンドモードの適用
- マスク適用
- サムネイル生成

#### MaskEditService (`lib/providers/mask_edit_provider.dart`)
マスク編集サービス：
- ブラシ描画
- グラデーションマスク生成
- マスク反転
- 空のマスク生成

### UI層

#### LayerPanel (`lib/widgets/layer_panel/`)
レイヤーパネルUI：
- `layer_panel.dart`: レイヤーリストとアクションボタン
- `layer_tile.dart`: 個別のレイヤータイル

#### MaskEditor (`lib/widgets/mask_editor/`)
マスク編集UI：
- `mask_toolbar.dart`: マスク編集ツールバー
- `mask_canvas.dart`: マスク描画キャンバス

#### LayerPreviewWidget (`lib/widgets/layer_preview_widget.dart`)
レイヤープレビュー：
- マルチレイヤーのリアルタイム合成表示
- チェッカーボード背景表示

## 使用方法

### レイヤーの追加

```dart
// 画像からレイヤーを追加
await ref.read(layerStackProvider.notifier).addLayer(
  image: uiImage,
  name: 'New Layer',
);
```

### レイヤーの編集

```dart
// 不透明度を変更
ref.read(layerStackProvider.notifier).setLayerOpacity(
  layerId,
  0.5, // 50%
);

// ブレンドモードを変更
ref.read(layerStackProvider.notifier).setLayerBlendMode(
  layerId,
  BlendMode.multiply,
);
```

### マスクの追加

```dart
// 空のマスクを追加
ref.read(layerStackProvider.notifier).addMaskToLayer(layerId);

// AI被写体抽出からマスクを作成
final maskImage = await aiService.generateMask(...);
ref.read(layerStackProvider.notifier).addMaskToLayer(
  layerId,
  maskImage: maskImage,
);
```

### マスクの編集

```dart
// ブラシサイズを変更
ref.read(maskEditSettingsProvider.notifier).setBrushSize(100);

// ツールを変更
ref.read(maskEditSettingsProvider.notifier).setTool(MaskTool.brush);
```

## 技術的な詳細

### 状態管理
- **Riverpod**: 状態管理フレームワーク
- **Freezed**: 不変データモデル
- **StateNotifier**: 状態変更の管理

### 画像処理
- **dart:ui**: Flutter UIフレームワークのImage API
- **Canvas**: 2D描画API
- **PictureRecorder**: オフスクリーンレンダリング

### パフォーマンス最適化
- デバウンス処理によるレイヤー合成の最適化
- 非同期処理によるUI応答性の維持
- サムネイル生成によるメモリ効率の向上

## 今後の拡張予定

### フェーズ2: 高度な機能
- [ ] レイヤーグループ（フォルダ）
- [ ] 調整レイヤー
- [ ] スマートオブジェクト
- [ ] レイヤースタイル（ドロップシャドウ、境界線等）

### フェーズ3: パフォーマンス最適化
- [ ] GPUシェーダーによる高速合成
- [ ] レイヤーキャッシュ機構
- [ ] バックグラウンド処理

### フェーズ4: 高度なマスク機能
- [ ] ベクターマスク
- [ ] カラーレンジ選択
- [ ] クイック選択ツール
- [ ] 境界線を調整

## ファイル構成

```
lib/
├── models/
│   ├── blend_mode.dart          # ブレンドモード列挙型
│   ├── layer.dart               # レイヤーモデル
│   ├── layer_mask.dart          # レイヤーマスクモデル
│   ├── layer_stack.dart         # レイヤースタックモデル
│   └── mask_tool.dart           # マスクツール定義
├── providers/
│   ├── layer_stack_provider.dart  # レイヤースタック管理
│   └── mask_edit_provider.dart    # マスク編集管理
├── services/
│   └── layer_compositor.dart      # レイヤー合成エンジン
└── widgets/
    ├── layer_panel/
    │   ├── layer_panel.dart       # レイヤーパネル
    │   └── layer_tile.dart        # レイヤータイル
    ├── mask_editor/
    │   ├── mask_toolbar.dart      # マスクツールバー
    │   └── mask_canvas.dart       # マスク描画キャンバス
    └── layer_preview_widget.dart  # レイヤープレビュー
```

## 依存関係

新規追加された依存関係：
- `uuid: ^4.5.1` - レイヤーIDの生成

## 貢献

このレイヤーシステムは、以下の設計原則に基づいています：
- **関心の分離**: モデル、Provider、サービス、UIの明確な分離
- **不変性**: Freezedによる不変データモデル
- **テスト可能性**: 各コンポーネントの独立性
- **拡張性**: 新機能の追加が容易な設計

---

**Version**: 1.0.0
**Last Updated**: 2026-01-13
