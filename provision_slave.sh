sudo pg_ctlcluster 9.5 main stop -m immediate && \
sudo -u postgres rm -rf /var/lib/postgresql/9.5/main/ && \
sudo -u postgres repmgr -h pg-master -U repmgr -d repmgr -D /var/lib/postgresql/9.5/main/ -f /etc/postgresql/9.5/main/repmgr.conf standby clone && \
sudo pg_ctlcluster 9.5 main start && \
sudo -u postgres repmgr -f /etc/postgresql/9.5/main/repmgr.conf standby register && \
sudo service repmgrd start 
