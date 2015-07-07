#!/bin/bash

if env | grep -q ^skip_domains=; then
    arr=$(echo $skip_domains | tr "," "\n")
    for x in $arr; do
        printf "127.0.0.1 $x\n" >> /etc/hosts
    done
fi

/usr/bin/supervisord -c /etc/supervisord.conf