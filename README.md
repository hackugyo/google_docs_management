# About

* Google Docsのコメントを，コメント位置つきで取得して，それをもとにgithubのissueを作成したかった

* [Manage Comments and Discussions  |  Drive REST API  |  Google Developers](https://developers.google.com/drive/v3/web/manage-comments)

## How to use

```
# After downloading client_id.json...
$ bundle install --path vendor/bundle
$ bundle exec ruby read_files.rb #{FILE_ID}
```

### Comments APIの問題

* Webから作ったコメントには，anchorとしてkix IDが割り振られる．GET時に得られる `Comment # anchor` は `kix.***********` が入っている．（[APIドキュメント](https://developers.google.com/drive/v3/reference/comments)と矛盾）
* API経由で作る際に，anchorとしてJSONを入れてcreateする．すると，GET時に得られる `Comment # anchor` は JSONが入っている．定義されていないキーもそのまま見えている．

  * `POST https://www.googleapis.com/drive/v3/files/fileId/comments` で,下記のようなリクエストを送ると，コメントは作成されるものの，狙った箇所にハイライトされない：
```
{
  "content": "api content json ver 6",
  "anchor": "{\"r\":6,\"a\":[{\"line\":{\"n\":1,\"l\":1, \"ml\": 1, \"description\":\"revision 6 line 1 - 1\"}}]}",
  "quotedFileContent": {
    "value": "123456789",
    "mimeType": "text/html"
  }
}
```

* なお，[Comments update API](https://developers.google.com/drive/v3/reference/comments/update)は，どちらから作ったコメントに対しても正しく動作する．
* [Rplies create API](https://developers.google.com/drive/v3/reference/replies/create)も問題ない．

* 参考：[google drive sdk - What is the format of the range field required to anchor a comment to a given cell? - Stack Overflow](http://stackoverflow.com/questions/17735387/what-is-the-format-of-the-range-field-required-to-anchor-a-comment-to-a-given-ce)

### 今後

* ハイライトを独自につけたらどうなるのか？
  * [Class Text  |  Apps Script  |  Google Developers](https://developers.google.com/apps-script/reference/document/text#setBackgroundColor)
  * [Highlight text and insert comment into specific Google Doc text - Stack Overflow](http://stackoverflow.com/questions/22055765/highlight-text-and-insert-comment-into-specific-google-doc-text/22060169#22060169)
