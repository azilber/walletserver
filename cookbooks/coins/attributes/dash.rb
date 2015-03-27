# -*- encoding : utf-8 -*-
default[:coins][:dash][:source] = 'https://github.com/darkcoin/darkcoin/archive/v0.11.1.26.tar.gz'
default[:coins][:dash][:executable] = 'dashd'
default[:coins][:dash][:client] = 'dash-cli'
default[:coins][:dash][:masternode] = FALSE
default[:coins][:dash][:rpc_user] = 'dash'
default[:coins][:dash][:rpc_pass] = '9aPXHYaWCqQ54FYXMBuKVsxQd2JoGgq7HunxDTt9mmQX'
default[:coins][:dash][:rpc_port] = '9998'
default[:coins][:dash][:rpc_allow_net] = '127.0.0.1'
default[:coins][:dash][:wallet_location] = 'S3'
default[:coins][:dash][:wallet_s3_bucket] = ''
default[:coins][:dash][:wallet_s3_key] = ''
default[:coins][:dash][:wallet_s3_secret] = ''

