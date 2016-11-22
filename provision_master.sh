sudo -u postgres repmgr -f /etc/postgresql/9.5/main/repmgr.conf master register && \
sudo service repmgrd start && \
sudo service keepalived start 
