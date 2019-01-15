# 0. 概要
これは、GitHubとJenkinsを連携させて、  
ビルドとデプロイ、ひいてはユニットテストの自動化の  
ノウハウを得る為の、動作検証用アプリケーションです。  
  
以下のような仕組みを、実現することが本プロジェクトの目的です。  

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
  
上記の設定とJenkins側でジョブを作成して、  
以下のように、ビルドのパラメータ化で『payload』を設定してやることで、  
ジョブで設定したシェルスクリプト内でJSON形式でコミット情報（ブランチ名など）を  
取得することができるようになります。
![68747470733a2f2f71696974612d696d6167652d73746f72652e73332e616d617a6f6e6177732e636f6d2f302f3236313332332f38333932386431312d616231612d663334352d326436612d6435663839643339326230642e706e67](https://user-images.githubusercontent.com/16982729/51126380-51d2a180-1866-11e9-9ccf-3981a1101473.png)
  
アプリケーションのビルドは、  
上記の機能を利用して、  
Jenkins側に、GitHubからのpushイベントの通知を、トリガーとして動くジョブを作成し、  
そのジョブから、以下のスクリプトを実行することによって実現しています。  
https://github.com/KatoRyota/test_jenkins/blob/develop/build.sh  
  
アプリケーションのデプロイは、  
Jenkins側に、ブランチ名をパラメータとして動くジョブを作成し、  
そのジョブから、以下のスクリプトを実行することによって実現しています。  
https://github.com/KatoRyota/test_jenkins/blob/develop/deploy.sh  
  
そして、デプロイが成功すると、アプリケーションサーバーが自動的に再起動され変更内容が反映されます。  
  
以下は、『 http://localhost:8080/hello 』にアクセスした時の画面です。  
　　⇒https://github.com/KatoRyota/test_jenkins/blob/master/main.py  
  
例）  
  
![screenshot_2019-01-14 screenshot](https://user-images.githubusercontent.com/16982729/51109394-7e6fc480-1838-11e9-9ad5-ddd9440cc5a5.png)

