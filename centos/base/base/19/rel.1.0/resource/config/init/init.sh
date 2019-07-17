#!/bin/bash
set -o errexit

## consul template config
if [[ ${DEPLOY_TARGET_URI} =~ "/prod2" ]]; then
    TOKEN_PREFIX="example_AWS2_"
elif [[ ${DEPLOY_TARGET_URI} =~ "/prod" ]]; then
    TOKEN_PREFIX="example_AWS_"
elif [[ ${DEPLOY_TARGET_URI} =~ '/release' ]]; then
    TOKEN_PREFIX="example_RELEASE_"
elif [[ ${DEPLOY_TARGET_URI} =~ '/rel' ]]; then
    TOKEN_PREFIX="example_REL_"
elif [[ 'Z'${DEPLOY_TARGET_URI} == 'Z' ]] ; then
    TOKEN_PREFIX=''
else
    TOKEN_PREFIX="example_LOCAL_"
fi

if [[ 'Z'${TOKEN_PREFIX} != 'Z' ]]; then

    ## OS type
    if [[ `uname` == 'Linux' ]];then
        OS=1
    else
        OS=0
    fi

    ## supervisor template
    sed -i "s|DEPLOY_TARGET_URI|${DEPLOY_TARGET_URI}|g" /config/template/supervisord.tpl

    VAULT_TOKEN=`aws ssm get-parameter --name "${TOKEN_PREFIX}VAULT_TOKEN" --with-decryption --output text 2>/dev/null | awk '{print $(NF-NUM)}' NUM="${OS}" `
    if [[ Z${VAULT_TOKEN} == 'Z' ]];then
        VAULT_TOKEN=`export AWS_DEFAULT_PROFILE=vault && aws ssm get-parameter --name "${TOKEN_PREFIX}VAULT_TOKEN" --with-decryption --output text  | awk '{print $(NF-NUM)}' NUM="${OS}"`
        unset AWS_DEFAULT_PROFILE
    fi
    CONSUL_TOKEN=`aws ssm get-parameter --name "${TOKEN_PREFIX}CONSUL_TOKEN" --with-decryption --output text 2>/dev/null | awk '{print $(NF-NUM)}' NUM="${OS}" `
    if [[ Z${CONSUL_TOKEN} == 'Z' ]];then
        CONSUL_TOKEN=`export AWS_DEFAULT_PROFILE=vault && aws ssm get-parameter --name "${TOKEN_PREFIX}CONSUL_TOKEN" --with-decryption --output text | awk '{print $(NF-NUM)}' NUM="${OS}"`
        unset AWS_DEFAULT_PROFILE
    fi

    sed -i "s|VAULT_TOKEN|${VAULT_TOKEN}|g" /config/apps/supervisord.hcl
    sed -i "s|CONSUL_TOKEN|${CONSUL_TOKEN}|g" /config/apps/supervisord.hcl

    ## generate supervisor config
    consul-template -config=/config/apps/supervisord.hcl -once

    ## release token in ram
    unset VAULT_TOKEN
    unset CONSUL_TOKEN

else
        mv /config/template/supervisord.conf /etc/supervisord.conf
fi