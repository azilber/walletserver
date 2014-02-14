name             'walletserver'
maintainer       'Alexey Zilber'
maintainer_email 'AlexeyZilber@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures walletserver'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "yum"
depends "yum-epel"
depends "apt"

recipe "default", "Sets up and installs the wallet server"
recipe "install_gperf", "Installs the Google Performance tools"
recipe "install_openssl", "Installs openssl"
recipe "install_bdb", "Installs Berkeley DB 4.8"
recipe "install_leveldb", "Installs Google LevelDB"
recipe "install_protobuf", "Installs Google Protocol Buffers"
recipe "install_boost", "Installs BOOST C++ libraries"
recipe "install_python3", "Installs Python 3.x"

attribute 'walletserver/root',
 :display_name => "Root of the wallet server",
 :description => "Root of the wallet server (ex. /opt/coins)",
 :required => "recommended",
 :recipes => [ "walletserver::default",
               "gperf::default" ],
 :default => "/opt/coins"
