# vagrant-php-phalcon-box
Vagrant box with Centos + Phalcon Framework + PHP + mailcatcher + wkhtmltopdf

## Overview

We use the default CentOS 6.4 64-bit ISO from Vagrant if your system is 64 bit, otherwise we use a 32-bit image.

When you provision Vagrant for the first time it's always the longest procedure (`$ vagrant up`). 
Vagrant will download the entire Linux OS if you've never used Vagrant or the CentOS Box. Afterwards, booting time is fast.

By default this setup uses 1024MB RAM. You can change this in `Vagrantfile` and simply run `$ vagrant reload`. You can also use more than one core if you like, simply add these two lines in the same file:

    v.customize ["modifyvm", :id, "--cpus", "2"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]

## Packages Included

- Centos 6.4 (64-Bit or 32-bit)
- LAMP Stack
  - Apache 2.2
  - PHP 5.3
  - MySQL 5.1
- [Phalcon 1.3.*](http://phalconphp.com/en/)
- [MongoDB 2.4.*](https://www.mongodb.org/)
- [Mailcatcher 0.5.12](https://github.com/sj26/mailcatcher) - Catches and shows mails instead of sending them
- ImageMagick 0.6
- phpMyAdmin 4
- SVN
- GIT
- ffmpeg 2
- [wkhtmltopdf + wkhtmltoimage command-line tools](http://wkhtmltopdf.org/)

## Requirements

- Operating System: Windows or OSX (not tested on Linux).
- [Virtualbox](https://www.virtualbox.org) version 4.3.*
- [Vagrant](http://www.vagrantup.com) version 1.*
- Ports 80 (apache), 3306 (mysql), 27017 (mongodb) and 1080 (mailcatcher) needs to be free.

## Installation

First you need a [Git enabled terminal](#software-suggestions). Then you should **clone this repository** locally.

    git clone https://github.com/maxgalbu/vagrant-php-phalcon-box.git

If you are on OSX, you need to install the vagrant-triggers plugin:

    vagrant plugin install vagrant-triggers

You may want to install the vagrant-vbguest plugin to keep the VirtualBox Guest Additions updated:

    vagrant plugin install vagrant-vbguest

Now you are ready to provision your Virtual Machine, chdir inside the folder where you cloned the repository and run:

    vagrant up

Vagrant will first download the CentOS box, then the puppet script in `manifests` will provision the machine. It will take at least 10 minutes, so go take a walk if you want. 

If you are on OSX, after provisioning the script will require your password to forward the port from 8080 to 80. This is needed because ports below 1024 are privileged ports that can be used if you are root. You can see what is run [here](https://github.com/maxgalbu/vagrant-php-phalcon-box/blob/master/Vagrantfile#L59-L69).

## How to SSH into the box

These are credentials setup by default:

- **Host Address**: localhost
- **SSH**: vagrant/vagrant or root/vagrant

Once provisioned, if you are on OSX or linux simply type:

```bash
    vagrant ssh
```

If you are on Windows, you can use [PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/) to access the VM.

## How to access the services:

- Apache: http://localhost/
- MySQL: localhost:3306
- mongodb: localhost:27017
- mailcatcher: http://localhost:1080

## Local Editing

On your Host computer open any file explorer or IDE and navigate to `/www/`. 
This folder is mounted to the Virtual Machine. Any changes to files within here will reflect
realtime changes in the Virtual Machine.

If you are using .git you should initialize your repository locally rather than on the server.
This way you will not have to import keys into your Virtual Machine.

## Software Suggestions

If you are using Linux you can use the built in Terminal to do everything.
The same goes with OSX.

For Windows, you can use [Git SCM](http://git-scm.com/) and Bash.
