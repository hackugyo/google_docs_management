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

  * `POST https://www.googleapis.com/drive/v3/files/fileId/comments` で下記のようなリクエストを送る：
```
{
  "content": "api content json ver 121",
  "anchor": "{\"r\":121,\"a\":[{\"line\":{\"o\":120,\"l\":5,\"description\":\"from c 120 to c 125\"}}]}",
  "quotedFileContent": {
    "value": "Lorem, Ipsum",
    "mimeType": "text/html"
  }
}
```

* 参考：[google drive sdk - What is the format of the range field required to anchor a comment to a given cell? - Stack Overflow](http://stackoverflow.com/questions/17735387/what-is-the-format-of-the-range-field-required-to-anchor-a-comment-to-a-given-ce)

