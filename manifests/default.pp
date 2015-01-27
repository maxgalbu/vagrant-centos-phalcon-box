group { 'puppet': ensure => present }
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

service { 'iptables':
	ensure => stopped,
}

file { "/etc/localtime":
	source => "file:///usr/share/zoneinfo/Europe/Rome",
	require => Package["tzdata"]
}

#Cambio i colori della shell
file_line { 'change $PS1 colors':
	ensure => 'present',
	path => '/home/vagrant/.bashrc',
	line => 'PS1="\[$(tput bold)\][\[$(tput setaf 1)\]\u\[$(tput setaf 4)\]@\h\[$(tput setaf 3)\] \W]\[$(tput setaf 7)\]\\$\[$(tput sgr0)\] "',
}

class { 'yum':
	extrarepo => [ 'epel' , 'rpmforge', 'wandisco', 'atrpms' ],
}
include yum::repo::atrpms

$packagelist = [
	'curl',
	'ImageMagick',
	'phpMyAdmin',
	'mc',
	'augeas',
	'tzdata',
	'ruby',
	'ruby-devel',
	'ruby-augeas',
	'zip',
]
package { $packagelist:
	ensure  => 'installed',
	require => Class['yum'],
}
package { 'subversion':
	ensure  => 'installed',
	require => Class['yum::repo::wandisco'],
}
package { 'ffmpeg':
	ensure  => 'installed',
	require => Class['yum::repo::atrpms'],
}
package { ['jpegoptim', 'optipng']: #per ottimizzare le immagini
	ensure  => 'installed',
	require => Class['yum::repo::epel'],
}
package { ['mongodb', 'mongodb-server']: #mongodb
	ensure  => 'installed',
	require => Class['yum::repo::epel'],
}

#Servizio mongodb server
service { 'mongod':
	ensure => 'running',
	require => Package['mongodb-server'],
}

#Installo phalcon
$phalconpackages = ['git','pcre-devel','gcc','make']
package { $phalconpackages: 
	ensure  => 'installed',
	require => [ Class['yum'], Class['php'] ],
}
vcsrepo { "/tmp/cphalcon":
	ensure => present,
	provider => git,
	source => 'https://github.com/phalcon/cphalcon',
	revision => 'master',
	require => Package[$phalconpackages],
}
exec { 'install phalcon':
	command => '/bin/bash install',
	cwd => '/tmp/cphalcon/build',
	user => root,
	require => Vcsrepo['/tmp/cphalcon'],
	unless => 'php -i | grep phalcon',
}
file { '/etc/php.d/phalcon.ini':
	source	=> "file:///vagrant/files/phalcon.ini",
	owner		=> root,
	group		=> root,
	require => [
		Exec['install phalcon'],
		Class['php']
	],
	notify  => Service['apache'],
}

#Installo mailcatcher
file { '/tmp/mailcatcher.gem':
	source	=> "file:///vagrant/files/mailcatcher.gem",
	owner		=> root,
	group		=> root,
}
package { 'mime-types':
	ensure  => '1.25.1',
	require => [ Package[$packagelist] ],
	provider => "gem"
}
package { 'tilt':
	ensure  => '1.4.1',
	require => [ Package['mime-types'] ],
	provider => "gem"
}
#Non posso usare package perchè puppet non accetta opzioni (--no-ri --no-rdoc)
exec { 'install mailcatcher':
	command  => "gem install /tmp/mailcatcher.gem --no-ri --no-rdoc",
	require => [ Package['mime-types'], Package['tilt'], File['/tmp/mailcatcher.gem'] ],
	unless => 'gem list | grep mailcatcher',
	timeout => 900,
}
exec { 'start mailcatcher':
	command			=> "mailcatcher --http-ip=0.0.0.0",
	require			=> Exec['install mailcatcher'],
}

#Installo wkhtmltopdf + wkhtmltoimage
file { '/usr/local/bin/wkhtmltopdf':
	source	=>"file:///vagrant/files/wkhtmltopdf",
	owner		=> root,
	group		=> root,
	mode		=> 755,
}
file { '/usr/local/bin/wkhtmltoimage':
	source	=>"file:///vagrant/files/wkhtmltoimage",
	owner		=> root,
	group		=> root,
	mode		=> 755,
}


#Configurazione di phpmyadmin da file
file { '/etc/phpMyAdmin/config.inc.php':
	source	=>"file:///vagrant/files/config.inc.php",
	owner		=> root,
	group		=> root,
	mode		=> 744,
	require	=> Package['phpMyAdmin']
}

#Installo apache
class { 'apache': }

apache::dotconf { 'custom':
	content => 'EnableSendfile Off',
}

apache::module { 'rewrite': }
apache::module { 'actions': }
apache::module { 'expires': }
apache::module { 'headers': }
apache::module { 'proxy_http': }
apache::module { 'proxy': }
apache::module { 'vhost_alias': }

apache::vhost { 'localhost':
	server_name   => 'localhost',
	serveraliases => [],
	docroot       => '/var/www/html',
	directoryconfig     => [{
		directory => '/var/www/html',
		allow_override => 'All',
	}, {
		directory => '/usr/share/phpMyAdmin',
		allow => 'Allow from all',
	}],
	port          => 80,
	env_variables => [],
	priority      => '1',
	aliases       => "/phpmyadmin /usr/share/phpMyAdmin"
}


#Installo php
class { 'php':
	service             => 'apache',
	service_autorestart => false,
	module_prefix       => 'php-',
	require => Class['yum'],
}

php::module { 'cli': }
php::module { 'mcrypt': }
php::module { 'soap': }
php::module { 'pdo': }
php::module { 'bcmath': }
php::module { 'gd': }
php::module { 'xml': }
php::module { 'pecl-mongo': }

class { 'php::devel':
	require => Class['php'],
}

#Modifico php.ini
augeas { 'php.ini default':
	context => "/files/etc/php.ini/PHP",
	changes   => [
		'set display_errors "On"',
		'set error_reporting -1',
		'set allow_url_fopen "On"',
		'set short_open_tag "On"',
		'set upload_max_filesize "500M"',
		'set post_max_size "500M"',
		'set memory_limit "510M"',
		'set error_reporting "E_ALL & ~E_NOTICE"',
		'set html_errors "On"',
		'set max_input_vars "1000000"',
	],
	notify  => Service['apache'],
	require => Class['php'],
}

augeas { 'php.ini date':
	context => "/files/etc/php.ini/Date",
	changes   => [
		'set date.timezone "Europe/Rome"',
	],
	notify  => Service['apache'],
	require => Class['php'],
}

augeas { 'php.ini mail':
	context => "/files/etc/php.ini/mail function",
	changes   => [
		'set sendmail_path "/usr/bin/env catchmail"',
	],
	notify  => Service['apache'],
	require => Class['php'],
}

augeas { 'php.ini xdebug':
	context => "/files/etc/php.ini/xdebug",
	changes   => [
		'set xdebug.default_enable 1',
		'set xdebug.remote_autostart 0',
		'set xdebug.remote_connect_back 1',
		'set xdebug.remote_enable 1',
		'set xdebug.remote_handler "dbgp"',
		'set xdebug.remote_port 9000'
	],
	notify  => Service['apache'],
	require => Class['php'],
}

augeas { 'mcrypt.ini':
	context => "/files/etc/php.d/mcrypt.ini/.anon",
	changes   => [
		'set extension "mcrypt.so"'
	],
	notify  => Service['apache'],
	require => Class['php'],
}

#Installo mysql server
class { 'mysql::server':
	root_password => undef,
	override_options => {
		mysqld => {
			'bind-address' => undef,
		}
	}
}