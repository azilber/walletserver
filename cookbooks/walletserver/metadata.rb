# -*- encoding : utf-8 -*-
name             'walletserver'
maintainer       'Alexey Zilber'
maintainer_email 'AlexeyZilber@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures walletserver'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

supports 'centos'
supports 'ubuntu'

depends "yum"
depends "yum-epel"
depends "apt"

recipe "walletserver::default", "Sets up and installs the wallet server"
recipe "walletserver::install_libunwind", "Install libunwind for gperf"
recipe "walletserver::install_gperf", "Installs the Google Performance tools"
recipe "walletserver::install_openssl", "Installs openssl"
recipe "walletserver::install_bdb", "Installs Berkeley DB 4.8"
recipe "walletserver::install_leveldb", "Installs Google LevelDB"
recipe "walletserver::install_protobuf", "Installs Google Protocol Buffers"
recipe "walletserver::install_boost", "Installs BOOST C++ libraries"
recipe "walletserver::install_python3", "Installs Python 3.x"

attribute 'walletserver/root',
 :display_name => "Root of the wallet server",
 :description => "Root of the wallet server (ex. /opt/coins)",
 :required => "recommended",
 :recipes => [ "walletserver::default",
               "gperf::default" ],
 :default => "/opt/coins"
