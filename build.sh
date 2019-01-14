#---------------------------------------------------------------------
# main.pyのビルドスクリプト
#
# 使い方
#     bash build.sh
#---------------------------------------------------------------------

set -eEu
export LANG=ja_JP.UTF-8

#---------------------------------------------------------------------
# スクリプトの設定を行います。
#---------------------------------------------------------------------
function configure() {
    # GitHub → Jenkins経由で環境変数『payload』がセットされ、
    # 本スクリプトが実行されます。
    PAYLOAD="${payload}"

    # アプリケーションのGitリポジトリ
    REPOSITORY='git@github.com:KatoRyota/test_jenkins.git'

    # デプロイ対象のブランチ
    DEPLOY_BRANCH=$(echo "${PAYLOAD}" | perl -MJSON::PP -ne '
        $payload_json = decode_json $_;
        $payload_json->{".ref"} =~ /refs\/heads\/(.*)/;
        print $1')

    # リリースモジュール
    RELEASE_MODULES="bottle.py build.sh deploy.sh main.py"

    # Jenkinsサーバーに配置されてるリリースモジュールのパス
    JENKINS_MODULES_DIR=/home/santa/jenkins/app/modules/
}

#---------------------------------------------------------------------
# スクリプトのエントリーポイント
#---------------------------------------------------------------------
function main() {
    trap 'on_error ${LINENO}' ERR
    configure
    initialize
    checkout_deploy_branch
    pack_release_modules
}

#---------------------------------------------------------------------
# デプロイ対象のブランチをチェックアウトします。
#---------------------------------------------------------------------
function checkout_deploy_branch() {
    cd ${JENKINS_MODULES_DIR}
    log "INFO" "${DEPLOY_BRANCH}ブランチをチェックアウトします。"
    rm -rf ${DEPLOY_BRANCH}.test_jenkins
    git clone ${REPOSITORY} ${DEPLOY_BRANCH}.test_jenkins
    git checkout ${DEPLOY_BRANCH}
}

#---------------------------------------------------------------------
# リリースモジュールをパッケージングします。
#---------------------------------------------------------------------
function pack_release_modules() {
    cd ${JENKINS_MODULES_DIR}${DEPLOY_BRANCH}.test_jenkins/
    log "INFO" "リリースモジュールをパッケージングします。"
    tar zcvf ${DEPLOY_BRANCH}.test_jenkins.tar.gz ${RELEASE_MODULES}
}

#---------------------------------------------------------------------
# アプリケーションの初期化処理を行います。
#---------------------------------------------------------------------
function initialize() {
    log "INFO" "作業ディレクトリを作成します。"
    mkdir -vp ${JENKINS_MODULES_DIR}
}

#---------------------------------------------------------------------
# エラー発生時の処理を行います。
#
# 本関数はtrapコマンドにより実行されます。
#
# line_no 行番号
#---------------------------------------------------------------------
function on_error() {
    local line_no=$1

    local message="${line_no}行目でエラーが発生した為、処理を中断しました。"
    log "ERROR" "${message}"
    exit 1
}

#---------------------------------------------------------------------
# ログメッセージを出力します。
#
# log_level ログレベル
# message メッセージ
#---------------------------------------------------------------------
function log() {
    local log_level="$1"
    local message="$2"

    local now_time=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    local log_message="${log_level} [${now_time}][line no:${BASH_LINENO[0]}] ${message}"

    echo "${log_message}"
}

main
