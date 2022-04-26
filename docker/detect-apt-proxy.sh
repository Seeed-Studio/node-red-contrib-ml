#!/bin/bash

APT_PROXY=$1

if [ $? -eq 0 ]; then
    cat >> /etc/apt/apt.conf.d/30proxy <<EOL
    Acquire::http::Proxy "$APT_PROXY";
EOL
    cat /etc/apt/apt.conf.d/30proxy
    echo "Using host's apt proxy"
else
    echo "No apt proxy detected on Docker host"
fi
