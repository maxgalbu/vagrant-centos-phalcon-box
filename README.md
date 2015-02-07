# vagrant-php-phalcon-box
Vagrant box with Centos + Phalcon Framework + PHP + mailcatcher + wkhtmltopdf

## Overview

We use the default CentOS 6.4 64-bit ISO from Vagrant if your system is 64 bit, otherwise we use a 32-bit image.

When you provision Vagrant for the first time it's always the longest procedure (`$ vagrant up`). 
Vagrant will download the entire Linux OS if you've never used Vagrant or the CentOS Box. Afterwards, booting time is fast.

By default this setup uses 1024MB RAM. You can change this in `Vagrantfile` and simply run `$ vagrant reload`. You can also use more than one core if you like, simply uncomment these two lines in the same file:

    v.customize ["modifyvm", :id, "--cpus", "2"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]

## Packages Included

- Centos 6.4 (64-Bit or 32-bit)
- LAMP Stack
  - Apache 2.2
  - PHP 5.3
  - MySQL 5.1
- [Phalcon 1.3](http://phalconphp.com/en/)
- [MongoDB 2.0.4](https://www.mongodb.org/)
- [Mailcatcher 0.5.12](https://github.com/sj26/mailcatcher) - Catches and shows mails instead of sending them
- ImageMagick
- phpMyAdmin
- SVN command-line client
- ffmpeg 2
- [wkhtmltopdf + wkhtmltoimage command-line tools](http://wkhtmltopdf.org/)
