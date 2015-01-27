def is_windows?
	# Detect if we are running on Windows
	processor, platform, *rest = RUBY_PLATFORM.split("-")
	platform == 'mingw32'
end
def is_64bit?
	if is_windows?
		ENV.has_key?('ProgramFiles(x86)')
	else
		['a'].pack('P').length > 4
	end
end
def is_not_vagrant11?
	output = `vagrant -v`
	matchdata = output.match(/1\.([0-9]+)\.[0-9]/) 
	return matchdata[1].to_i > 1
end

Vagrant.configure("2") do |config|
	if is_64bit?
		config.vm.box = "centos-6.4-x64"
		config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box"
	else
		config.vm.box = "centos-6.4-x86"
		config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-i386-v20130427.box"
	end
	
	if is_windows?
		config.vm.network :forwarded_port, guest: 80, host: 80
	else
		config.vm.network :forwarded_port, guest: 80, host: 8080
	end
	
	config.vm.network :forwarded_port, guest: 1080, host: 1080
	config.vm.network :forwarded_port, guest: 3306, host: 3306 #mysql
	config.vm.network :forwarded_port, guest: 27017, host: 27017 #mongodb
	config.ssh.forward_agent = true
	
	config.vm.provider :virtualbox do |v|
		v.customize ["modifyvm", :id, "--memory", 1024]
		v.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
		v.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
		v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]
		v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/www", "1"]
	end
	
	if is_not_vagrant11?
		config.vm.synced_folder "./www", "/var/www/html", :mount_options => ["dmode=777", "fmode=777"]
	else
		config.vm.synced_folder "./www", "/var/www/html", :extra => "dmode=777,fmode=777"
	end

	config.vm.provision :puppet, run: "always" do |puppet|
		puppet.manifests_path = "manifests"
		puppet.module_path = "modules"
		puppet.options = ['--verbose']
	end
	
	if !is_windows?
		config.trigger.after [:provision, :up, :reload] do
			system('echo "
				rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 80 -> 127.0.0.1 port 8080
				" | sudo pfctl -f - > /dev/null 2>&1; sudo pfctl -e; echo "==> Fowarding Ports: 80 -> 8080"')  
		end
		
		config.trigger.after [:halt, :destroy] do
			system("sudo pfctl -f /etc/pf.conf > /dev/null 2>&1; echo '==> Removing Port Forwarding'")
		end
	end
end
