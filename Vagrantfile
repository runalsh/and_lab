# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"
  config.vm.box_check_update = false

  config.vm.provision "shell", privileged: true, inline: <<-SHELL
	timedatectl set-timezone Europe/Moscow
	systemctl stop chronyd && systemctl disable chronyd
	apt-get update
	apt install iproute2 traceroute net-tools nmon wget curl conntrack -y
	sudo mkdir /root/.ssh/
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAr53uTiK0O/sbacgMcsHGp2mL0XvjpxI9O6n2KOPduFbmwKF/ZxLZm6nR1K6Dkj5aeg+BEFft1lrkh08ubJCYkF7/5vXy5dlzlLokCwc3aEOIIxD2WsOaFizmiy/b3KE16bvpkM7WzydlW6LyTaF3BoAikiw5D5IibroSij2mFWGVieXxXJSyryu+xmsNqGywuKc+4DjoaqEJJooBU53OdTkg8RGeN4dCrEWbJIc7agl5MDaBpL8aO6vH4OuGM7u3UFCTgDe6KRlK+bgYs4QEqb55RiNIp0vAOET4jH2QBhP489+5R1V6B/ozx2n0rDo3F3Hrha2Cp835KGoJVl2Gmw== rsa-key-20211028"  > /home/vagrant/.ssh/authorized_keys2
	sudo cp /vagrant/Desktop/universal_priv_rsa /home/vagrant/.ssh/
	sudo cp /home/vagrant/.ssh/authorized_keys2 /root/.ssh/ &&	sudo cp /home/vagrant/.ssh/universal_priv_rsa /root/.ssh/
	chmod 600 /home/vagrant/.ssh/authorized_keys2 && chmod 600 /home/vagrant/.ssh/universal_priv_rsa
	chown vagrant /home/vagrant/.ssh/universal_priv_rsa &&	chown vagrant /home/vagrant/.ssh/authorized_keys2
	chmod 600 /root/.ssh/universal_priv_rsa && chmod 600 /root/.ssh/authorized_keys2
	SHELL

  
# db
  config.vm.define "db" do |db|
	db.vm.network :forwarded_port, guest: 22, host: 2255
	
	db.vm.disk :disk, name: "lvm_f1", size: "100MB"
    db.vm.disk :disk, name: "lvm_f2", size: "100MB"
    db.vm.disk :disk, name: "mdraid_b1", size: "110MB"
    db.vm.disk :disk, name: "mdraid_b2", size: "110MB"	
    db.vm.network "private_network", virtualbox__intnet: "intra2", ip: "192.168.20.2"
	db.vm.network "private_network", virtualbox__intnet: "manage", ip: "192.168.30.2"
	#добавить run once
	db.vm.provision "lvm_raid", type: "shell", inline: <<-SHELL
		apt install mdadm lvm2 -y
		mkdir -p /local/files
		pvcreate /dev/sdb /dev/sdc /dev/sdd /dev/sde
		vgcreate lvm /dev/sdb /dev/sdc
		lvcreate -l 100%FREE -n lv1 lvm
		mkfs.ext4 /dev/lvm/lv1
		mount -t ext4 /dev/lvm/lv1 /local/files
		rm -rf /local/files/lost+found
		
		mkdir -p /local/backups
		mdadm --create --verbose /dev/md0 --level 0 --raid-devices=2 /dev/sdd /dev/sde
		mkfs.ext4 -m 0 /dev/md0
		mount -t ext4 /dev/md0 /local/backups
		chown vagrant /local/backups  && chown vagrant /local/files
		rm -rf /local/backups/lost+found
	SHELL
	
	db.vm.provision "postgre_pgadmin", type: "shell", privileged: false, inline: <<-SHELL
		sudo apt install postgresql python3 python3-pip python-dev libpcre3 libpcre3-dev python3-venv virtualenv libpq-dev --no-install-recommends --no-install-suggests -y
		sudo mkdir /var/lib/pgadmin
		sudo mkdir /var/log/pgadmin
		sudo chown $USER /var/lib/pgadmin
		sudo chown $USER /var/log/pgadmin
		python3 -m venv pgadmin4
		cp /vagrant/Desktop/db/pgadmin4.db /home/vagrant/ && cp /home/vagrant/pgadmin4.db /var/lib/pgadmin/
		cd /home/vagrant/
		source pgadmin4/bin/activate
		pip install pgadmin4
		cp /vagrant/Desktop/db/pgadmin4.service /home/vagrant/ && sudo cp /home/vagrant/pgadmin4.service /etc/systemd/system/
		sudo systemctl daemon-reload && sudo systemctl enable pgadmin4.service && sudo systemctl start pgadmin4.service
	SHELL
	
	db.vm.provision "db_init", type: "shell", privileged: true, inline: <<-SHELL
		pip3 install psycopg2 psycopg2-binary flask
		cp /vagrant/Desktop/db/{postgremagazines.csv,postgreinit.sql,postgremydb.sql} /home/vagrant/ 
		sudo -u postgres psql -f /home/vagrant/postgreinit.sql
		sudo -u vagrant psql mydb -f /home/vagrant/postgremydb.sql
		sudo cp  /vagrant/Desktop/db/postgresql.conf /home/vagrant/ && sudo cp /home/vagrant/postgresql.conf /etc/postgresql/13/main/
		sudo echo "host mydb vagrant 192.168.10.2/32 md5" >> /etc/postgresql/13/main/pg_hba.conf
		sudo service postgresql restart
	SHELL
	db.vm.provision "script2_provisioning", type: "shell", privileged: true, inline: <<-SHELL
		cp /vagrant/Desktop/db/{sc2.cfg,sc2.sh,sc2.service} /home/vagrant/
		cp /home/vagrant/sc2.cfg /etc/
		chmod +x /home/vagrant/sc2.sh
		cp /home/vagrant/sc2.service /etc/systemd/system/ && systemctl daemon-reload && systemctl start sc2.service && systemctl enable sc2.service
		SHELL
	db.vm.provision "script1_provisioning", type: "shell", inline: "cp /vagrant/Desktop/db/sc1.sh /home/vagrant/ && chmod +x /home/vagrant/sc1.sh"
	db.vm.network "forwarded_port", guest: 5050, host: 5050
	db.vm.network "forwarded_port", guest: 5432, host: 5432
	#db.vm.provision "route", type: "shell", inline: "sudo route del default && sudo ip route add default via 192.168.20.3"
	db.vm.provision "dns_server_db", type: "shell", privileged: true, inline: <<-SHELL
		echo "nameserver 192.168.20.3" > /etc/resolv.conf
		SHELL
	#db.vm.provision "get trusted cert from web", type: "shell", inline: "scp -i ~/.ssh/universal_priv_rsa root@web.runalsh.local:/etc/ssl/certs/web.runalsh.local.crt /usr/local/share/ca-certificates && update-ca-certificates"
	#db.vm.provision "get trusted cert from router for mitm", type: "shell", inline: "scp -i ~/.ssh/universal_priv_rsa root@router.runalsh.local:/root/.mitmproxy/mitmproxy-ca-cert.pem /usr/local/share/ca-certificates && update-ca-certificates"
  end


 # router
  config.vm.define "router" do |router|
	router.vm.network :forwarded_port, guest: 22, host: 2244
	router.vm.network "forwarded_port", guest: 3000, host: 3000
  	router.vm.provider "virtualbox" do |ram|
		ram.memory = 2000
		end
    router.vm.network "private_network", virtualbox__intnet: "intra2", ip: "192.168.20.3"
	router.vm.network "private_network", virtualbox__intnet: "intra1", ip: "192.168.10.3"
	router.vm.network "private_network", virtualbox__intnet: "log", ip: "192.168.40.1"
	router.vm.network "private_network", virtualbox__intnet: "manage", ip: "192.168.30.1"
	
	router.vm.provision "dns_server", type: "shell", privileged: true, inline: "apt install dnsmasq -y && cp -rf /vagrant/Desktop/router/{dnsmasq.conf,resolv.conf,hosts} /home/vagrant/ && cp -rf /home/vagrant/ {dnsmasq.conf,resolv.conf,hosts} /etc && systemctl restart dnsmasq"
	router.vm.provision "ipforw_routing", type: "shell", inline: "sudo sysctl -w net.ipv4.ip_forward=1 && sysctl -p && iptables -P FORWARD ACCEPT"
	router.vm.provision :docker
	router.vm.provision :docker_compose
	router.vm.provision "prom_graf", type: "shell", inline: "cp -r /vagrant/desktop/router/prom_graf /home/vagrant/ && docker-compose -f /home/vagrant/prom_graf/docker-compose.yml up -d"
	router.vm.provision "nodeexp_local", type: "shell", privileged: true, inline: "wget  https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz &&  tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz && mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/ && useradd -rs /bin/false node_exporter && cp -r /vagrant/desktop/router/node_exporter.service /home/vagrant/ && cp -r /home/vagrant/node_exporter.service /etc/systemd/system/ && systemctl daemon-reload && systemctl start node_exporter && systemctl enable node_exporter"
	#db.vm.provision "prepare mimtm stage", type: "shell", inline: "apt install mitmproxy -y && iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j REDIRECT --to-port 8080"
  end   
 

# elk
  config.vm.define "elk" do |elk|
	elk.vm.network :forwarded_port, guest: 22, host: 2233
	elk.vm.network "private_network", virtualbox__intnet: "log", ip: "192.168.40.2"
	elk.vm.network :forwarded_port, guest: 5044, host: 5044
	elk.vm.provision "vmem", type: "shell", inline: "sudo sysctl vm.max_map_count=262144"

	elk.vm.provider "virtualbox" do |v|
		v.memory = 5000
		end
	elk.vm.provision "docker" do |d|
		# d.run "sebp/elk:671", args: "-p 5601:5601 -p 9200:9200 -p 5044:5044 -it -e ELASTIC_PASSWORD=runalsh"
		d.run "sebp/elk:671", args: "-p 5601:5601 -p 5044:5044 -it -e ELASTIC_PASSWORD=runalsh"

		end
	elk.vm.provision "log_off_ssl", type: "shell", inline: <<-SHELL 
		# docker exec -ti sebp-elk-671 sh -c "echo 'input {  beats {    port => 5044  }}' > /etc/logstash/conf.d/02-beats-input.conf"
		cp /vagrant/desktop/elk/02-beats-input.conf /home/vagrant/
		docker cp /home/vagrant/02-beats-input.conf sebp-elk-671:/etc/logstash/conf.d/02-beats-input.conf
		docker cp sebp-elk-671:/etc/pki/tls/certs/logstash-beats.crt /home/vagrant/ && docker cp sebp-elk-671:/etc/pki/tls/private/logstash-beats.key /home/vagrant/ && docker restart sebp-elk-671
		SHELL
	# alternative - we can copy key and crt from sebp-elk and use it without disabling ssl encryption  
	#elk.vm.provision "route", type: "shell", inline: "sudo route del default && sudo ip route add default via 192.168.40.1"
	elk.vm.provision "dns_server_elk", type: "shell", privileged: true, inline: <<-SHELL
		echo "nameserver 192.168.40.1" > /etc/resolv.conf
		SHELL
  end   
  
# web
  config.vm.define "web" do |web|
	web.vm.network :forwarded_port, guest: 22, host: 2211
	web.vm.network "private_network", virtualbox__intnet: "intra1", ip: "192.168.10.2"
	web.vm.network "private_network", virtualbox__intnet: "manage", ip: "192.168.30.3"
	web.vm.network "public_network"
	web.vm.network "forwarded_port", guest: 80, host: 80
	web.vm.network "forwarded_port", guest: 443, host: 443
	web.vm.provision "nginx_local", type: "shell", privileged: true, inline: "sudo apt install nginx php-fpm php-pgsql python3 python3-pip  libpq-dev ssl-cert -y && pip3 install psycopg2 && sudo mkdir -p /local/scripts && make-ssl-cert generate-default-snakeoil && sudo chown vagrant /local/scripts  && cp /vagrant/Desktop/web/nginx_default /home/vagrant/ && sudo cp /home/vagrant/nginx_default /etc/nginx/sites-available/default && cp /vagrant/Desktop/web/1.php /home/vagrant/ && sudo cp /home/vagrant/1.php /local/scripts && sudo echo extension=pdo_pgsql >> /etc/php/7.4/fpm/php.ini && sudo echo extension=pgsql >> /etc/php/7.4/fpm/php.ini && sudo service php7.4-fpm restart && cp /vagrant/Desktop/web/web.runalsh.local.* /home/vagrant/ && sudo cp /home/vagrant/web.runalsh.local.crt /etc/ssl/certs/  && sudo cp /home/vagrant/web.runalsh.local.key /etc/ssl/private/ && cp /home/vagrant/web.runalsh.local.crt /usr/local/share/ca-certificates && update-ca-certificates && sudo service nginx restart && cp /usr/share/nginx/html/index.html /local/"
	web.vm.provision "python_script", type: "shell", privileged: true, inline: <<-SHELL
		pip3 install psycopg2 PrettyTable
		cp /vagrant/Desktop/web/2.py /home/vagrant/ && sudo cp /home/vagrant/2.py /local/scripts
		crontab -l > pythoncron
		echo "*/1 * * * * python3 /local/scripts/2.py" >> pythoncron
		crontab pythoncron
		SHELL
	web.vm.provision "filebeat", type: "shell", privileged: true, inline: "cp /vagrant/desktop/web/filebeat.yml /home/vagrant &&  wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.16.0-amd64.deb && sudo dpkg -i filebeat-7.16.0-amd64.deb && sudo filebeat modules enable system nginx  && sudo cp /home/vagrant/filebeat.yml /etc/filebeat/filebeat.yml  && sudo service filebeat restart && sudo service filebeat enable"
	#sudo filebeat setup       filebeat-e
	web.vm.provision "dns_server_web", type: "shell", privileged: true, inline: <<-SHELL
		echo "nameserver 192.168.10.3" > /etc/resolv.conf
		SHELL
	web.vm.provision "mount local/files from db", type: "shell", privileged: true, inline: "apt install sshfs -y && mkdir -p /local/files && sshfs -o allow_other,ro,IdentityFile=/home/vagrant/.ssh/universal_priv_rsa root@db.runalsh.local:/local/files /local/files"	
	#web.vm.provision "route", type: "shell", inline: "sudo route del default && sudo ip route add default via 192.168.10.3"
  end    
  
end 