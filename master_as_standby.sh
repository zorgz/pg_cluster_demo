# rewind db changes 
MASTER_SERVER=$1

sudo service repmgrd stop
# clean shutdow of the pg server needed  (required  in case server was interrupted forcibly)
sudo pg_ctlcluster 9.5 main start && sudo pg_ctlcluster 9.5 main stop -m fast 
# pg_rewind works only with cleanly stopped database server
sudo -u postgres /usr/lib/postgresql/9.5/bin/pg_rewind -D /var/lib/postgresql/9.5/main/ --source-server="host=$NEW_MASTER dbname=repmgr user=repmgr" && \
# follow master (creates recovery.conf)
sudo -u postgres repmgr -f /etc/postgresql/9.5/main/repmgr.conf -h $MASTER_SERVER -U repmgr -d repmgr -D /var/lib/postgresql/9.5/main/ standby follow && \
# reregister slave (updates db records)
sudo -u postgres repmgr -F -f /etc/postgresql/9.5/main/repmgr.conf standby register && \
# start auto failover agent 
sudo service repmgrd start && \
# keepalive should be stopped
sudo service keepalived stop


