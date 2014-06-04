# -*- encoding : utf-8 -*-
#
# Cookbook Name:: coins
# Recipe:: setup_darkcoin
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

#  include_attribute "coins::darkcoin"

log "Install #{node[:coins][:darkcoin][:executable]} into #{node[:walletserver][:root]}"


  directory "#{node[:walletserver][:root]}/build/darkcoin" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

  template "#{node[:walletserver][:root]}/build/darkcoin/makefile.darkcoin.unix" do
    source "makefile.darkcoin.unix.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0644
  end

log "Configuring #{node[:coins][:darkcoin][:executable]} with rpc_allow_net=#{node[:coins][:darkcoin][:rpc_allow_net]}, port #{node[:coins][:darkcoin][:rpc_port]}"

  template "#{node[:walletserver][:root]}/configs/#{node[:coins][:darkcoin][:executable]}.conf" do
    source "coin.conf.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:darkcoin][:executable],
       :rpcuser => node[:coins][:darkcoin][:rpc_user],
       :rpcpass => node[:coins][:darkcoin][:rpc_pass],
       :rpcnet => node[:coins][:darkcoin][:rpc_allow_net],
       :rpcport => node[:coins][:darkcoin][:rpc_port]
    })
    mode 0600
  end


  template "#{node[:walletserver][:root]}/control/start-#{node[:coins][:darkcoin][:executable]}.sh" do
    source "control-start-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:darkcoin][:executable]
    })
    mode 0700
  end

  template "#{node[:walletserver][:root]}/control/stop-#{node[:coins][:darkcoin][:executable]}.sh" do
    source "control-stop-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:darkcoin][:executable],
       :rpcuser => node[:coins][:darkcoin][:rpc_user],
       :rpcpass => node[:coins][:darkcoin][:rpc_pass]
    })
    mode 0700
  end

  directory "#{node[:walletserver][:root]}/data/#{node[:coins][:darkcoin][:executable]}" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0700
    recursive true
  end


  template "/etc/monit.d/darkcoin.conf" do
    source "monit_default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:darkcoin][:executable],
       :coinuser => node[:walletserver][:daemon][:user],
       :coingroup => node[:walletserver][:daemon][:group],
       :rpchost => "127.0.0.1",
       :rpcport => node[:coins][:darkcoin][:rpc_port]
    })
    mode 0600
  end


  s3_file "#{node[:walletserver][:root]}/data/#{node[:coins][:darkcoin][:executable]}/wallet.dat" do
     remote_path "/wallet.dat"
     bucket node[:coins][:darkcoin][:wallet_s3_bucket]
     aws_access_key_id node[:coins][:darkcoin][:wallet_s3_key]
     aws_secret_access_key node[:coins][:darkcoin][:wallet_s3_secret]
     owner node[:walletserver][:daemon][:user]
     group node[:walletserver][:daemon][:group]
     mode 0600
     action :create
     only_if { node[:coins][:darkcoin][:wallet_s3_secret] != '' }
  end

  remote_file "#{Chef::Config[:file_cache_path]}/darkcoin.tar.gz" do
         source node[:coins][:darkcoin][:source]
         mode "0644"
         backup false
         action :create_if_missing
         notifies :run, 'bash[setup_darkcoin]', :immediately
         notifies :reload, 'service[monit]', :immediately
  end

  bash "setup_darkcoin" do
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

      tar -xzvp --strip-components 1 -f #{Chef::Config[:file_cache_path]}/darkcoin.tar.gz -C #{node[:walletserver][:root]}/build/darkcoin/
      (cd #{node[:walletserver][:root]}/build/darkcoin/src  && make -f #{node[:walletserver][:root]}/build/darkcoin/makefile.darkcoin.unix )

      strip #{node[:walletserver][:root]}/build/darkcoin/src/#{node[:coins][:darkcoin][:executable]}

      mv -f #{node[:walletserver][:root]}/build/darkcoin/src/#{node[:coins][:darkcoin][:executable]} #{node[:walletserver][:root]}/daemons/

    EOH
    action :nothing
  end

