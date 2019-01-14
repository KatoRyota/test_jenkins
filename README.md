# 0. 概要
これは、GitHubとJenkinsを連携させて、
ビルドとデプロイ、ひいてはユニットテストの自動化の
ノウハウを得る為の、動作検証用アプリケーションです。

仕組みとしては、以下のようになっています。

```txt
    1. ユーザーが、デプロイ対象のブランチをリポジトリ（GitHub）にpushする。
    2. GitHubが、Jenkinサーバーに対して、pushイベント（HTTPリクエスト）を通知する。
    3. Jenkinsが、pushされた、デプロイ対象のブランチをチェックアウトして、
       デプロイ対象ディレクトリに配置する。
    4. ユーザーが、Jenkinsのデプロイジョブを実行して、デプロイ対象のブランチをデプロイする。
```

# 1. 詳細

以下に詳細を記載します。

GitHub → Jenkinsへの通知は、
以下のように、GitHub側にWebhookの設定を行うことで実現しています。

![screenshot_2019-01-14 katoryota test_jenkins 1](https://user-images.githubusercontent.com/16982729/51110006-57b28d80-183a-11e9-9ed2-4b348e3fe54c.png)

アプリケーションのビルドは、
Jenkins側に、GitHubからのpushイベントの通知を、トリガーとして動くジョブを作成し、
そのジョブから、以下のスクリプトを実行することによって実現しています。
https://github.com/KatoRyota/test_jenkins/blob/develop/build.sh

アプリケーションのデプロイは、
Jenkins側に、ブランチ名をパラメータとして動くジョブを作成し、
そのジョブから、以下のスクリプトを実行することによって実現しています。
https://github.com/KatoRyota/test_jenkins/blob/develop/deploy.sh

そして、デプロイされると、アプリケーションサーバーが自動的に再起動され変更内容が反映されます。

例）

![screenshot_2019-01-14 screenshot](https://user-images.githubusercontent.com/16982729/51109394-7e6fc480-1838-11e9-9ad5-ddd9440cc5a5.png)
