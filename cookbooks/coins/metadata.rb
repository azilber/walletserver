name             'coins'
maintainer       'Alexey Zilber'
maintainer_email 'AlexeyZilber@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures coins'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

supports 'centos'

depends "walletserver"
depends "s3_file"

recipe "coins::default", "Sets up and preps for coin installs"
recipe "coins::setup_bitcoin", "Installs bitcoind"

attribute 'coins/generic/source',
 :display_name => "Url of generic coin source",
 :description => "A url for a tar.gz source archive of a generic cryptocoin, forked from Bitcoin/Litecoin",
 :required => "recommended",
 :recipes => [ "coins::default",
               "coins::setup_generic" ]

attribute 'coins/generic/executable',
 :display_name => "Name of Daemon/Executable",
 :description => "Name of Daemon/Executable (ex. 'bitcoind')",
 :required => "recommended",
 :recipes => [ "coins::default",
               "coins::setup_generic" ]

attribute 'coins/generic/rpc_port',
 :display_name => "rpc_port for coin",
 :description => "Port for rpc, (ex. 8332)",
 :required => "recommended",
 :recipes => [ "coins::default",
               "coins::setup_generic" ]

attribute 'coins/generic/rpc_user',
 :display_name => "rpc_user for coin",
 :description => "Username for rpc",
 :required => "recommended",
 :recipes => [ "coins::default",
               "coins::setup_generic" ]

attribute 'coins/generic/rpc_pass',
 :display_name => "rpc_pass for coin",
 :description => "Password for rpc_user",
 :required => "recommended",
 :recipes => [ "coins::default",
               "coins::setup_generic" ]

attribute 'coins/generic/rpc_allow_net',
 :display_name => "rpc_allow_net",
 :description => "rpc_allow_net",
 :required => "recommended",
 :recipes => [ "coins::default",
               "coins::setup_generic" ],
 :default => "127.0.0.1"


attribute 'coins/generic/wallet_location',
 :display_name => "wallet_location",
 :description => "wallet_location",
 :required => "optional",
 :recipes => [ "coins::default",
               "coins::setup_generic" ],
 :default => "S3"

attribute 'coins/generic/wallet_s3_user',
 :display_name => "wallet_3_user",
 :description => "wallet_s3_user",
 :required => "optional",
 :recipes => [ "coins::default",
               "coins::setup_generic" ],
 :default => ""

attribute 'coins/generic/wallet_s3_secret',
 :display_name => "wallet_s3_secret",
 :description => "wallet_s3_secret",
 :required => "optional",
 :recipes => [ "coins::default",
               "coins::setup_generic" ],
 :default => ""

attribute 'coins/generic/wallet_s3_bucket',
 :display_name => "wallet_s3_bucket",
 :description => "wallet_s3_bucket",
 :required => "optional",
 :recipes => [ "coins::default",
               "coins::setup_generic" ],
 :default => ""


