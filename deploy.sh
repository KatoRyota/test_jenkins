#---------------------------------------------------------------------
# main.pyの起動スクリプト
#
# 使い方
#     bash main.sh
#---------------------------------------------------------------------

set -eEu
export LANG=ja_JP.UTF-8


function configure () {
    APP_PARENT_DIR=/home/santa/app/
    APP_ROOT_DIR=${APP_PARENT_DIR}test_jenkins/
    APP_MODULES_DIR=${APP_PARENT_DIR}modules/
}

function main () {
    configure

    cd ${APP_ROOT_DIR}

    if [[ -e pid.txt && -n pid.txt ]]; then
        kill `cat pid.txt`
    fi

    cd ${APP_PARENT_DIR}

    unlink test_jenkins || echo "unlink対象なし。"
    ln -vs ${APP_MODULES_DIR}${deploy_branch}.test_jenkins test_jenkins

    cd ${APP_ROOT_DIR}
    : >pid.txt
    python main.py &
    echo $! >pid.txt
}

main
