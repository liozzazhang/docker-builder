#!/usr/bin/env bash

switch_flag=${REPO}
if [[ ${switch_flag} == 'centos' ]];then
    rm -rf /etc/yum.repos.d/example*
    sed -i "s|enabled=0|enabled=1|g" /etc/yum.repos.d/centos*
fi