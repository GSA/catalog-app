#!/bin/bash

# add license signature to saxon-license.lic
 if ! [ -z "$SIGNATURE" ]; then
    echo Signature=$SIGNATURE >> /etc/saxon-license.lic
 fi

# run tomcat
catalina.sh run
