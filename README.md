noans
====================

とてもシンプルな身内向けSNS

_Really simple SNS thought to use closed community_
Used *Sinatra* - Simple and small web framework written in Ruby

### Feature
- ファイルのアップロードを中心とした設計
    - 公開範囲の変更 (自分のみ or 全体へ公開)
    - アップロードしたファイルをまとめるマイリスト機能
         - ニコニコ動画のマイリスト機能に近いです
    - アップロードした Markdown のプレビュー

### Background
- Ruby
- Sinatra
- DataMapper
- and more...

### Usage
```bash
$ git clone https://github.com/kyontan/noans.git
$ cd noans
$ bundle
$ rackup
```

### Future...
- 箇条書きを中心とした、複数人で編集可能なドキュメント作成機能
- Markdownの作成, 編集機能
- ファイルの公開範囲のより詳細な設定
- テーマの分離
- Angular.JSなどのクライアントサイドJSの導入
- 多言語対応


### License
This application is licensed under the MIT License.

==================
Kyontan (kyontan@live.jp)
