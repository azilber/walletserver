# -*- encoding : utf-8 -*-
#
# Cookbook Name:: coins
# Recipe:: setup_litecoin
#
# Copyright 2014, Alexey Zilber
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#  include_attribute "coins::litecoin"

log "Install #{node[:coins][:litecoin][:executable]} into #{node[:walletserver][:root]}"


  directory "#{node[:walletserver][:root]}/build/litecoin" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

  template "#{node[:walletserver][:root]}/build/litecoin/makefile.litecoin.unix" do
    source "makefile.litecoin.unix.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0644
  end

log "Configuring #{node[:coins][:litecoin][:executable]} with rpc_allow_net=#{node[:coins][:litecoin][:rpc_allow_net]}, port #{node[:coins][:litecoin][:rpc_port]}"

  template "#{node[:walletserver][:root]}/configs/#{node[:coins][:litecoin][:executable]}.conf" do
    source "coin.conf.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:litecoin][:executable],
       :rpcuser => node[:coins][:litecoin][:rpc_user],
       :rpcpass => node[:coins][:litecoin][:rpc_pass],
       :rpcnet => node[:coins][:litecoin][:rpc_allow_net],
       :rpcport => node[:coins][:litecoin][:rpc_port]
    })
    mode 0600
  end


  template "#{node[:walletserver][:root]}/control/start-#{node[:coins][:litecoin][:executable]}.sh" do
    source "control-start-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:litecoin][:executable]
    })
    mode 0700
  end

  template "#{node[:walletserver][:root]}/control/stop-#{node[:coins][:litecoin][:executable]}.sh" do
    source "control-stop-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:litecoin][:executable],
       :rpcuser => node[:coins][:litecoin][:rpc_user],
       :rpcpass => node[:coins][:litecoin][:rpc_pass]
    })
    mode 0700
  end

  directory "#{node[:walletserver][:root]}/data/#{node[:coins][:litecoin][:executable]}" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0700
    recursive true
  end


  template "/etc/monit.d/litecoin.conf" do
    source "monit_default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:litecoin][:executable],
       :coinuser => node[:walletserver][:daemon][:user],
       :coingroup => node[:walletserver][:daemon][:group],
       :rpchost => "127.0.0.1",
       :rpcport => node[:coins][:litecoin][:rpc_port]
    })
    mode 0600
  end


  s3_file "#{node[:walletserver][:root]}/data/#{node[:coins][:litecoin][:executable]}/wallet.dat" do
     remote_path "/wallet.dat"
     bucket node[:coins][:litecoin][:wallet_s3_bucket]
     aws_access_key_id node[:coins][:litecoin][:wallet_s3_key]
     aws_secret_access_key node[:coins][:litecoin][:wallet_s3_secret]
     owner node[:walletserver][:daemon][:user]
     group node[:walletserver][:daemon][:group]
     mode 0600
     action :create
     only_if { node[:coins][:litecoin][:wallet_s3_secret] != '' }
  end

  remote_file "#{Chef::Config[:file_cache_path]}/litecoin.tar.gz" do
         source node[:coins][:litecoin][:source]
         mode "0644"
         backup false
         action :create_if_missing
         notifies :run, 'bash[setup_litecoin]', :immediately
         notifies :reload, 'service[monit]', :immediately
  end

  bash "setup_litecoin" do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH
      export LDFLAGS="#{node[:walletserver][:ldflags]}"
      export CPPFLAGS="#{node[:walletserver][:cppflags]}"

      export BOOST_LIB_PATH="#{node[:walletserver][:root]}/lib"
      export BDB_LIB_PATH="#{node[:walletserver][:root]}/lib"
      export OPENSSL_LIB_PATH="#{node[:walletserver][:root]}/lib"
      export BOOST_INCLUDE_PATH="#{node[:walletserver][:root]}/include/boost"
      export BDB_INCLUDE_PATH="#{node[:walletserver][:root]}/include"
      export OPENSSL_INCLUDE_PATH="#{node[:walletserver][:root]}/include/openssl"

      tar -xzvp --strip-components 1 -f #{Chef::Config[:file_cache_path]}/litecoin.tar.gz -C #{node[:walletserver][:root]}/build/litecoin/
      (cd #{node[:walletserver][:root]}/build/litecoin/src  && make -f #{node[:walletserver][:root]}/build/litecoin/makefile.litecoin.unix )

      strip #{node[:walletserver][:root]}/build/litecoin/src/#{node[:coins][:litecoin][:executable]}

      mv -f #{node[:walletserver][:root]}/build/litecoin/src/#{node[:coins][:litecoin][:executable]} #{node[:walletserver][:root]}/daemons/

    EOH
    action :nothing
  end

