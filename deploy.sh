#---------------------------------------------------------------------
# main.pyのデプロイスクリプト
#
# 使い方
#     bash deploy.sh
#---------------------------------------------------------------------

set -eEu
export LANG=ja_JP.UTF-8

#---------------------------------------------------------------------
# スクリプトの設定を行います。
#---------------------------------------------------------------------
function configure() {
    # Jenkinsが環境変数『deploy_branch』をセットし、
    # 本スクリプトを実行します。
    DEPLOY_BRANCH="${deploy_branch}"

    # scpコマンド用のJenkinsサーバーのドメインを適宜設定すること。
    JENKINS_SERVER=""

    # Jenkinsサーバーに配置されてるリリースモジュールのパス
    JENKINS_MODULES_DIR=/home/santa/jenkins/app/modules/
    # 公開サーバーに配置されてるアプリケーションパスの親
    APP_PARENT_DIR=/home/santa/app/
    # 公開サーバーに配置されてるアプリケーションパス
    APP_ROOT_DIR=${APP_PARENT_DIR}test_jenkins/
    # 公開サーバーに配置されてるリリースモジュールのパス
    APP_MODULES_DIR=${APP_PARENT_DIR}modules/
}

#---------------------------------------------------------------------
# スクリプトのエントリーポイント
#---------------------------------------------------------------------
function main() {
    trap 'on_error ${LINENO}' ERR
    configure
    initialize
    stop_app
    get_release_modules
    distribute
    start_app
}

#---------------------------------------------------------------------
# アプリケーションを停止します。
#---------------------------------------------------------------------
function stop_app() {
    cd ${APP_ROOT_DIR}
    log "INFO" "アプリケーションを停止します。"
    if [[ -e pid.txt && -n pid.txt ]]; then
        kill `cat pid.txt`
    fi
}

#---------------------------------------------------------------------
# Jenkinsサーバーからリリースモジュールを取得します。
#---------------------------------------------------------------------
function get_release_modules() {
    scp -vp \
        ${JENKINS_SERVER}${JENKINS_MODULES_DIR}${DEPLOY_BRANCH}.test_jenkins/${DEPLOY_BRANCH}.test_jenkins.tar.gz \
        ${APP_MODULES_DIR}${DEPLOY_BRANCH}.test_jenkins/

    cd ${APP_MODULES_DIR}${DEPLOY_BRANCH}.test_jenkins/
    log "INFO" "リリースモジュールを取得します。"
    tar zxvf ${DEPLOY_BRANCH}.test_jenkins.tar.gz
    rm -v ${DEPLOY_BRANCH}.test_jenkins.tar.gz
}

#---------------------------------------------------------------------
# アプリケーションをサービス提供可能な状態にします。
#
# アプリケーションパスのシムリンクを、
# デプロイ対象ブランチのモジュールへのパスに変更します。
#---------------------------------------------------------------------
function distribute() {
    cd ${APP_PARENT_DIR}
    log "INFO" "アプリケーションパスのシムリンクを変更します。"
    unlink test_jenkins || log "INFO" "unlink対象なし。"
    ln -vs ${APP_MODULES_DIR}${DEPLOY_BRANCH}.test_jenkins test_jenkins
}

#---------------------------------------------------------------------
# アプリケーションを起動します。
#---------------------------------------------------------------------
function start_app() {
    cd ${APP_ROOT_DIR}
    log "INFO" "アプリケーションを起動します。"
    : >pid.txt
    python main.py &
    echo $! >pid.txt
}

#---------------------------------------------------------------------
# アプリケーションの初期化処理を行います。
#---------------------------------------------------------------------
function initialize() {
    log "INFO" "作業ディレクトリを作成します。"
    mkdir -vp ${APP_ROOT_DIR}
    mkdir -vp ${APP_MODULES_DIR}${DEPLOY_BRANCH}.test_jenkins/
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
