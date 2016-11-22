# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.

   # common configuration for all VMs,
  # requires plugins:
  #
  # vagrant plugin install vagrant-omnibus
  # vagrant plugin install salty-vagrant-grains
  # vagrant plugin install vagrant-hostmanager
  #
  # suggest plugins:
  #
  # vagrant plugin install vagrant-cachier
  # vagrant plugin install vagrant-vbguest

  config.vm.box = "ubuntu/trusty64"
  
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.auto_detect = true
    config.cache.enable :chef
    config.cache.enable :apt
  else
    puts 'WARN: Vagrant-cachier plugin not detected. Continuing unoptimized.'
  end

  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = true
  else
    puts 'WARN: vagrant-vbguest plugin not detected.'
  end

  config.ssh.insert_key = false

  if Vagrant.has_plugin?('vagrant-hostmanager')
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
    config.hostmanager.include_offline = true
    config.vm.provision :hostmanager
  else
    puts 'WARN: vagrant-hostmanager plugin not detected.'
  end

    config.vm.provision "file", source: "keys", destination: "/tmp/postgres/keys/"
    config.vm.provision "file", source: "files/postgresql.conf", destination: "/tmp/postgres/postgresql.conf"
    config.vm.provision "file", source: "files/pg_hba.conf", destination: "/tmp/postgres/pg_hba.conf"
    config.vm.provision "file", source: "files/start.conf", destination: "/tmp/postgres/start.conf"
    config.vm.provision "file", source: "repmgrd", destination: "/tmp/"
    config.vm.provision "file", source: "keepalived/keepalived.conf", destination: "/tmp/keepalived/etc/init/keepalived.conf"

    config.vm.provision :shell, path: "bootstrap.sh"    

  config.vm.define :pg_master do |pg_master_config|
    pg_master_config.vm.host_name = 'pg-master'
    pg_master_config.vm.network :private_network, :ip => '10.100.0.101', :netmask => '255.255.0.0'
    pg_master_config.vm.network "forwarded_port", guest: 5432, host: 5450
    
    pg_master_config.vm.provider 'virtualbox' do |v|
      v.name = 'pg-master'
      v.memory = 512
      # v.customize ['modifyvm', :id, '--cpus', '2']
      # Disable DNS proxy. FIXME? It seems like this should be
      # on, but enabling it results in a 5 second delay for any
      # HTTP requests.
      v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    end

    pg_master_config.vm.provision "file", source: "files/repmgr.conf.master", destination: "/tmp/postgres/repmgr.conf"
    pg_master_config.vm.provision "file", source: "keepalived/keepalived.conf.master", destination: "/tmp/keepalived/keepalived.conf"

    pg_master_config.vm.provision :shell, path: "provision_postgres.sh"
    # target user and postgres has to be in place before settings up ssh
    pg_master_config.vm.provision :shell, path: "ssh_passwordless.sh"
    pg_master_config.vm.provision :shell, path: "provision_master.sh"

  end

  config.vm.define :pg_slave do |pg_slave_config|
    pg_slave_config.vm.host_name = 'pg-slave'
    pg_slave_config.vm.network :private_network, :ip => '10.100.0.102', :netmask => '255.255.0.0'
    pg_slave_config.vm.network "forwarded_port", guest: 5432, host: 5451
  
    pg_slave_config.vm.provider 'virtualbox' do |v|
      v.name = 'pg-slave'
      v.memory = 512
      # v.customize ['modifyvm', :id, '--cpus', '2']
      # Disable DNS proxy. FIXME? It seems like this should be
      # on, but enabling it results in a 5 second delay for any
      # HTTP requests.
      v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    end

    pg_slave_config.vm.provision "file", source: "files/repmgr.conf.slave", destination: "/tmp/postgres/repmgr.conf"
    pg_slave_config.vm.provision "file", source: "keepalived/keepalived.conf.slave", destination: "/tmp/keepalived/keepalived.conf"

    pg_slave_config.vm.provision :shell, path: "provision_postgres.sh"
    # target user and postgres has to be in place before setting up ssh
    pg_slave_config.vm.provision :shell, path: "ssh_passwordless.sh" 
    pg_slave_config.vm.provision :shell, path: "provision_slave.sh" args: "pg-master"

  end

  config.vm.define :balancer do |balancer_config|
    balancer_config.vm.host_name = 'balancer'
    balancer_config.vm.network :private_network, :ip => '10.100.0.103', :netmask => '255.255.0.0'
    balancer_config.vm.network "forwarded_port", guest: 6432, host: 6432
    
    balancer_config.vm.provider 'virtualbox' do |v|
      v.name = 'balancer'
      v.memory = 256
      # v.customize ['modifyvm', :id, '--cpus', '2']
      # Disable DNS proxy. FIXME? It seems like this should be
      # on, but enabling it results in a 5 second delay for any
      # HTTP requests.
      v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    end

    balancer_config.vm.provision :file, source: "files/haproxy.cfg", destination: "/tmp/balancer/haproxy.cfg"
    balancer_config.vm.provision :file, source: "files/pgbouncer.ini", destination: "/tmp/balancer/pgbouncer.ini"
    balancer_config.vm.provision :file, source: "files/userlist.txt", destination: "/tmp/balancer/userlist.txt"
    
    balancer_config.vm.provision :shell, path: "provision_balancer.sh"
  end

  
  # Not useful for our scenario of master-slave one-to-one
  # config.vm.define :pg_witness do |pg_witness_config|
  #   pg_witness_config.vm.host_name = 'pg-witness'
  #   pg_witness_config.vm.network :private_network, :ip => '10.100.0.103', :netmask => '255.255.0.0'
  #   pg_witness_config.vm.network "forwarded_port", guest: 5432, host: 5452
  #   pg_witness_config.vm.network :forwarded_port, guest: 22, host: 2250

  #   pg_witness_config.vm.provider 'virtualbox' do |v|
  #     v.name = 'pg-witness'
  #     v.memory = 256
  #     # v.customize ['modifyvm', :id, '--cpus', '2']
  #     # Disable DNS proxy. FIXME? It seems like this should be
  #     # on, but enabling it results in a 5 second delay for any
  #     # HTTP requests.
  #     v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
  #   end

  #   pg_witness_config.vm.provision "file", source: "files/postgresql.conf.witness", destination: "/tmp/postgres/postgresql.conf.override"
  #   pg_witness_config.vm.provision "file", source: "files/repmgr.conf.witness", destination: "/tmp/postgres/repmgr.conf"

  #   config.vm.provision :shell, path: "provision_postgres.sh"
  #   # target user and postgres has to be in place before settings up ssh
  #   config.vm.provision :shell, path: "ssh_passwordless.sh"
    
  #   pg_witness_config.vm.provision :shell, path: "provision_witness.sh"

  # end  


end
