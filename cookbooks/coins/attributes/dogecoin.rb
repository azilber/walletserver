# -*- encoding : utf-8 -*-
default[:coins][:dogecoin][:source] = 'https://github.com/dogecoin/dogecoin/archive/master-1.6.tar.gz'
default[:coins][:dogecoin][:executable] = 'dogecoind'
default[:coins][:dogecoin][:rpc_user] = 'dogecoin'
default[:coins][:dogecoin][:rpc_pass] = '9aPXHYaWCqQ54FYXMBuKVsxQd2JoGgq7HunxDTt9mmQX'
default[:coins][:dogecoin][:rpc_port] = '22555'
default[:coins][:dogecoin][:rpc_allow_net] = '127.0.0.1'
default[:coins][:dogecoin][:wallet_location] = 'S3'
default[:coins][:dogecoin][:wallet_s3_bucket] = ''
default[:coins][:dogecoin][:wallet_s3_key] = ''
default[:coins][:dogecoin][:wallet_s3_secret] = ''

