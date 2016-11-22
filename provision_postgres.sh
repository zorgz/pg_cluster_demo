#Provision PostgreSQL 9.5

# Install the postgres key
echo "Importing PostgreSQL key and installing software"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main 9.5" >> /etc/apt/sources.list.d/pgdg.list
sudo apt-get update && \
sudo apt-get -y install postgresql-9.5 postgresql-client-9.5 postgresql-contrib-9.5 && \
sudo apt-get -y install postgresql-9.5-repmgr && \
sudo apt-get -y install keepalived && \
sudo -u postgres psql postgres -c "ALTER USER postgres WITH ENCRYPTED PASSWORD 'postgres'" && \
sudo -u postgres psql postgres -c "CREATE EXTENSION if not exists pg_stat_statements;" && \
sudo -u postgres createuser -s repmgr && \
sudo -u postgres createdb repmgr -O repmgr && \
find /tmp/postgres -maxdepth 1 -type f | sudo -u postgres xargs -I {} cp {} /etc/postgresql/9.5/main && \
sudo -u postgres mkdir -p /var/lib/postgresql/repmgr || \
sudo -u postgres cp /tmp/repmgrd/bin/* /var/lib/postgresql/repmgr/ && \
sudo cp /tmp/keepalived/etc/init/keepalived.conf /etc/init/ && \
sudo cp /tmp/keepalived/keepalived.conf /etc/keepalived/ && \
sudo pg_ctlcluster 9.5 main restart -m immediate && \
sudo sh -c "echo 'postgres ALL = NOPASSWD: ALL' >> /etc/sudoers" && \
sudo cp /tmp/repmgrd/* /etc/init/ && \
sudo initctl reload-configuration 
