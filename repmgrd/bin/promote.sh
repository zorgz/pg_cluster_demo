#!/usr/bin/env bash
set -u
set -e

repmgr standby promote -f /etc/postgresql/9.5/main/repmgr.conf && \
sudo sed -i 's/priority [0-9]*/priority 101/g' /etc/keepalived/keepalived.conf && \
sudo service keepalived start
