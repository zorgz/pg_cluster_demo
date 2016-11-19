# Passwordless .ssh 
sudo -u postgres mkdir ~postgres/.ssh
sudo cp /tmp/postgres/keys/* ~postgres/.ssh
sudo chmod go-rwx ~postgres/.ssh/*
sudo chown -R postgres.postgres ~postgres/.ssh
sudo chmod -R go-rwx ~postgres/.ssh
