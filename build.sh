#---------------------------------------------------------------------
# main.pyの起動スクリプト
#
# 使い方
#     bash main.sh
#---------------------------------------------------------------------

set -eEu
export LANG=ja_JP.UTF-8

function configure() {
    REPOSITORY='git@github.com:KatoRyota/test_jenkins.git'
    DEPLOY_BRANCH="develop"

    JENKINS_MODULES_DIR=/home/santa/jenkins/app/modules/
    APP_PARENT_DIR=/home/santa/app/
    APP_ROOT_DIR=${APP_PARENT_DIR}test_jenkins/
    APP_MODULES_DIR=${APP_PARENT_DIR}modules/

    RELEASE_MODULES="bottle.py build.sh deploy.sh main.py"
}

function main() {
    mkdir -vp ${JENKINS_MODULES_DIR}

    cd ${JENKINS_MODULES_DIR}

    rm -rf ${DEPLOY_BRANCH}.test_jenkins
    git clone ${REPOSITORY} ${DEPLOY_BRANCH}.test_jenkins
    git checkout ${DEPLOY_BRANCH}

    cd ${JENKINS_MODULES_DIR}${DEPLOY_BRANCH}.test_jenkins/

    tar zcvf ${DEPLOY_BRANCH}.test_jenkins.tar.gz ${RELEASE_MODULES}

    mkdir -vp ${APP_MODULES_DIR}${DEPLOY_BRANCH}.test_jenkins/

    scp -vp ${DEPLOY_BRANCH}.test_jenkins.tar.gz ${APP_MODULES_DIR}${DEPLOY_BRANCH}.test_jenkins/

    cd ${APP_MODULES_DIR}${DEPLOY_BRANCH}.test_jenkins/

    tar zxvf ${DEPLOY_BRANCH}.test_jenkins.tar.gz
    rm -v ${DEPLOY_BRANCH}.test_jenkins.tar.gz
}

main
