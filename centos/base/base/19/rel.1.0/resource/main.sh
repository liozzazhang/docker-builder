#!/bin/bash
set -o errexit

## run other scripts ##
if  $(ls /config/init/ >/dev/null 2>&1 ) ; then
  for init in /config/init/*.sh; do
    sh ${init}
    if [[ ${init} == '/config/init/init.sh' ]] || [[ ${init} == '/config/init/switch_repo.sh' ]]; then
    rm -rf ${init}
    fi
  done
fi

# remove token
rm -rf /config/apps/
rm -rf /config/template/

## start supervisor ##
ls -ld /opt/logs/supervisor/ >/dev/null 2>&1 || mkdir -p /opt/logs/supervisor
/usr/bin/supervisord -c /etc/supervisord.conf -n

