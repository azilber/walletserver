# -*- encoding : utf-8 -*-
default[:coins][:litecoin][:source] = 'https://github.com/litecoin-project/litecoin/archive/v0.8.6.9.tar.gz'
default[:coins][:litecoin][:executable] = 'litecoind'
default[:coins][:litecoin][:rpc_user] = 'litecoin'
default[:coins][:litecoin][:rpc_pass] = '9aPXHYaWCqQ54FYXMBuKVsxQd2JoGgq7HunxDTt9mmQX'
default[:coins][:litecoin][:rpc_port] = '9332'
default[:coins][:litecoin][:rpc_allow_net] = '127.0.0.1'
default[:coins][:litecoin][:wallet_location] = 'S3'
default[:coins][:litecoin][:wallet_s3_bucket] = ''
default[:coins][:litecoin][:wallet_s3_key] = ''
default[:coins][:litecoin][:wallet_s3_secret] = ''

