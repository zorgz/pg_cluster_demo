##Very simple PG clsuter setup for HA based on repmgrd 

Requires vagrant + virtual box

### General implementation notes 

Two server configuration : Master-Hot standby
pg_master
pg_slave
+ balancer node (calcal

Witness servers is not used in this setup

### To start using: 
   vagrant up pg_master pg_slave balancer
   

### Deployment scheme
  pg_master:
  	pg (running) 
  	repmgrd (running)
  	keepalived (running)

  pg_slave:
    pg (running/read-only)
    remmgrd (running)
    keepalived (stopped)

### Auto failover mechanics: 
 Repmgrd process should be up and running in order to make autofailover possible.
 Once master server went down for any reason (pg is down, out of network) the failover scenario triggers to execute.
 Depending on several repmgr timeouts (highly configurable) the decision can take some arbitraty time.
 Usually it is quite a few reconnect attempts to master server within a few minutes window.
 If still not accessible - /var/lib/postgresql/repgmr/promote.sh script runs.
 It does two main things: 
   1. Execute "promotion" - takes out standby from replications and makes it to accept write requests
   2. Spin up keepalived service with increased priority than on the old master server 
      This serves as a fencing of previously failed master (even if it goes back online it is going to have lower priority than current active master server which means it should not be resolved as active by keepalived).
  
### Auto failover decision time

 PG is down:

 Network is down: 


### Caveates 
 1. Automatic failover is pretty dangerous thing and should be considered as such.
    For instance take a look at the following  scenario:
       Master server's network went down. 
       Standby promoted to a master and gets some amount of changes.
       The network of the old master becomes available again.
       All of a sudden, networking connectivity of the new master server goes down (shit happens).
       Now we have keepalived service running on both machines.
       (Engineer has not yet stepped in, all is going on in automatic mode)
       Keepalived on old master quickly realizes the another service is not available.
       Now it is sure it has to be fallback one and start handling clients(now it is of the highest priority among the two)
       So all DB traffic now is served by old master.
       Depending on how prompt is an engineer on duty the data loss can be significant.
    
    
