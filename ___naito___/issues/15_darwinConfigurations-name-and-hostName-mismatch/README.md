# Issue 15: darwinConfigurations name and hostName are inconsistent

## 課題

現在の `flake.nix` で `darwinConfigurations` の名前と `networking.hostName` の設定が不整合になっている。

- `darwinConfigurations."naito-naito"` (flake.nix:35)
- `networking.hostName = "Mac-big"` (flake.nix:39)

この不整合により、設定の意図が不明確になっている。

## 解決方法

以下の 2 つの選択肢がある:

### 選択肢 1: hostName を darwinConfigurations 名に合わせる

```nix
networking.hostName = "naito-naito";
```

### 選択肢 2: darwinConfigurations 名を hostName に合わせる

```nix
darwinConfigurations."Mac-big" = nix-darwin.lib.darwinSystem {
```

この場合、コマンドも変更が必要:
```bash
darwin-rebuild switch --flake .#Mac-big
```

## 推奨解決策

選択肢 2 を採用する。理由:
- `Mac-big` は既存のシステム設定として定着している
- ホスト名の変更は他のシステム設定に影響する可能性がある
- 設定名を実際のホスト名に合わせる方が直感的

## 実装箇所

- ファイル: `flake.nix`
- 行: 35, 39
- 変更: 
  - `darwinConfigurations."naito-naito"` → `darwinConfigurations."Mac-big"`
  - コマンド: `darwin-rebuild switch --flake .#Mac-big`