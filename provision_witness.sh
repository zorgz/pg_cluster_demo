sudo pg_ctlcluster 9.5 main stop -m immediate

sudo -u postgres rm -rf /var/lib/postgresql/9.5/main/
sudo -u postgres repmgr -f /etc/postgresql/9.5/main/repmgr.conf witness create -D /var/lib/postgresql/9.5/main/
sudo -u postgres repmgr -f /etc/postgresql/9.5/main/repmgr.conf witness register

sudo service repmgrd start

