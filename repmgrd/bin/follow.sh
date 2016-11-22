#!/usr/bin/env bash
set -u
set -e

repmgr standby follow -f /etc/postgresql/9.5/main/repmgr.conf && \
sudo service keepalived stop
