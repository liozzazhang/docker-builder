#!/bin/bash

if [[ 'Z'${RESOLVER} != 'Z' ]]; then
   sed -i "s|{RESOLVER}|resolver ${RESOLVER};|" /etc/nginx/nginx.conf
else
   sed -i '/{RESOLVER}/d' /etc/nginx/nginx.conf
fi