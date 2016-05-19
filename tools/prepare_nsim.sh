#!/bin/bash

mkdir -p /opt
tar -xzf /scripts/resources/support.tar.gz -C /opt --strip-components=1

export NSIM_HOME=/opt/nSIM
