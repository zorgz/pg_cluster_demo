#Provision haproxy
# NOT WORKING YET 
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -  
sudo echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main 9.5" >> /etc/apt/sources.list.d/pgdg.list
sudo add-apt-repository ppa:vbernat/haproxy-1.6 && \
sudo apt-get update && \ 
sudo apt-get -y install haproxy && \ 
sudo apt-get install -y pgbouncer  && \
sudo cp /tmp/balancer/haproxy.cfg /etc/haproxy/ && \
sudo cp /tmp/balancer/pgbouncer.ini /etc/pgbouncer/ && \
sudo cp /tmp/balancer/userlist.txt /etc/pgbouncer/ && \
sudo service haproxy restart  &&  \
sudo service pgbouncer restart