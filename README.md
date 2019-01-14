# 概要
これは、GitHubとJenkinsを連携させて、
ビルドとデプロイ、ひいてはユニットテストの自動化の
ノウハウを得る為の、動作検証用アプリケーションです。

仕組みとしては、以下のような流れになっています。

```txt
    1. ユーザーが、デプロイ対象のブランチをリポジトリ（GitHub）にpushする。
    2. GitHubが、Jenkinサーバーに対して、pushイベント（HTTPリクエスト）を通知する。
    3. Jenkinsが、デプロイ対象のブランチをチェックアウトして、リリースディレクトリに配置する。
    4. ユーザーが、Jenkinsのデプロイジョブを実行して、デプロイ対象のブランチをデプロイする。
```

![screenshot_2019-01-14 katoryota test_jenkins](https://user-images.githubusercontent.com/16982729/51109034-461bb680-1837-11e9-824d-7f1e00f5379e.png)
