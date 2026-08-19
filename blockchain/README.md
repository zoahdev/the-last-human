# 区块链锚定（免费）

本书的内容哈希通过 [OpenTimestamps](https://opentimestamps.org) 免费锚定到比特币区块链。OpenTimestamps 使用日历服务器聚合哈希，并周期性提交到比特币交易中——免费、去中心化、无需任何费用。

## 已锚定的文件（2026-08-19）

| 文件 | SHA-256 | OTS 时间戳 |
|---|---|---|
| 全库哈希清单（4820 个文件） | 见 manifest 文件 | `manifest-20260819-165710.txt.ots` |
| 中文合订本 `zh/book-zh.md` | 见 manifest | `book-zh.md.ots` |
| 中文 MD 交付稿 | 见 manifest | `The-Last-Human-zh.md.ots` |
| 中文 TXT 交付稿 | 见 manifest | `The-Last-Human-zh.txt.ots` |
| 中文 EPUB 交付稿 | 见 manifest | `The-Last-Human-zh.epub.ots` |

## 如何验证

1. 在 [opentimestamps.org](https://opentimestamps.org) 上传任意被盖章的文件与对应的 `.ots` 文件；
2. 或使用 `ots verify` 命令行工具：`ots verify <文件>`；
3. 时间戳最终会被聚合进比特币区块链，成为不可篡改的存在证明。

## 说明

- 盖章完全免费：OpenTimestamps 日历服务器免费接受摘要，锚定成本由日历池承担。
- 每个 `.ots` 文件记录的是对应文件的 SHA-256 摘要与日历承诺链；一旦日历将其写入比特币区块，任何人都无法否认该文件在此时间点已存在。
- 本目录中的 `stamp.ps1` 用于对任意文件生成新的 OTS 时间戳。
