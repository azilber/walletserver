# -*- encoding : utf-8 -*-
default[:walletserver][:root] = "/opt/coins"
default[:walletserver][:daemon][:user] = "coins"
default[:walletserver][:daemon][:group] = "coins"
default[:walletserver][:alert][:email] = "walletserver@mailtothis.com"
default[:walletserver][:gperf][:source_file] = 'https://gperftools.googlecode.com/files/gperftools-2.1.tar.gz'
#default[:walletserver][:openssl][:source_file] = 'http://www.openssl.org/source/openssl-1.0.1f.tar.gz'
default[:walletserver][:openssl][:source_file] = 'http://ftp.nluug.nl/security/openssl/openssl-1.0.1f.tar.gz'
default[:walletserver][:bdb][:source_file] = 'http://download.oracle.com/berkeley-db/db-4.8.30.tar.gz'
default[:walletserver][:boost][:source_file] = 'http://jaist.dl.sourceforge.net/project/boost/boost/1.54.0/boost_1_54_0.tar.gz'
default[:walletserver][:leveldb][:source_file] = 'https://leveldb.googlecode.com/files/leveldb-1.15.0.tar.gz'
default[:walletserver][:protobuf][:source_file] = 'https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.bz2'
default[:walletserver][:python3][:source_file] = 'http://www.python.org/ftp/python/3.3.4/Python-3.3.4.tgz'
