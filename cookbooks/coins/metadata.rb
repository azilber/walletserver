name             'coins'
maintainer       'Alexey Zilber'
maintainer_email 'AlexeyZilber@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures coins'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "walletserver"

recipe "default", "Sets up and preps for coin installs"
recipe "setup_bitcoin", "Installs bitcoind"
