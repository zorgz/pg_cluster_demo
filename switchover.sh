sudo -u postgres repmgr -f /etc/postgresql/9.5/main/repmgr.conf standby switchover -v && \
sudo service repmgrd restart