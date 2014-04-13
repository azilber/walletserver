# -*- encoding : utf-8 -*-
#
# Cookbook Name:: coins
# Recipe:: setup_dogecoin
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

#  include_attribute "coins::dogecoin"

log "Install #{node[:coins][:dogecoin][:executable]} into #{node[:walletserver][:root]}"


  directory "#{node[:walletserver][:root]}/build/dogecoin" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

  template "#{node[:walletserver][:root]}/build/dogecoin/makefile.dogecoin.unix" do
    source "makefile.dogecoin.unix.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0644
  end

log "Configuring #{node[:coins][:dogecoin][:executable]} with rpc_allow_net=#{node[:coins][:dogecoin][:rpc_allow_net]}, port #{node[:coins][:dogecoin][:rpc_port]}"

  template "#{node[:walletserver][:root]}/configs/#{node[:coins][:dogecoin][:executable]}.conf" do
    source "coin.conf.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:dogecoin][:executable],
       :rpcuser => node[:coins][:dogecoin][:rpc_user],
       :rpcpass => node[:coins][:dogecoin][:rpc_pass],
       :rpcnet => node[:coins][:dogecoin][:rpc_allow_net],
       :rpcport => node[:coins][:dogecoin][:rpc_port]
    })
    mode 0600
  end


  template "#{node[:walletserver][:root]}/control/start-#{node[:coins][:dogecoin][:executable]}.sh" do
    source "control-start-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:dogecoin][:executable]
    })
    mode 0700
  end

  template "#{node[:walletserver][:root]}/control/stop-#{node[:coins][:dogecoin][:executable]}.sh" do
    source "control-stop-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:dogecoin][:executable],
       :rpcuser => node[:coins][:dogecoin][:rpc_user],
       :rpcpass => node[:coins][:dogecoin][:rpc_pass]
    })
    mode 0700
  end

  directory "#{node[:walletserver][:root]}/data/#{node[:coins][:dogecoin][:executable]}" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0700
    recursive true
  end


  template "/etc/monit.d/dogecoin.conf" do
    source "monit_default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:dogecoin][:executable],
       :coinuser => node[:walletserver][:daemon][:user],
       :coingroup => node[:walletserver][:daemon][:group],
       :rpchost => "127.0.0.1",
       :rpcport => node[:coins][:dogecoin][:rpc_port]
    })
    mode 0600
  end


  s3_file "#{node[:walletserver][:root]}/data/#{node[:coins][:dogecoin][:executable]}/wallet.dat" do
     remote_path "/wallet.dat"
     bucket node[:coins][:dogecoin][:wallet_s3_bucket]
     aws_access_key_id node[:coins][:dogecoin][:wallet_s3_key]
     aws_secret_access_key node[:coins][:dogecoin][:wallet_s3_secret]
     owner node[:walletserver][:daemon][:user]
     group node[:walletserver][:daemon][:group]
     mode 0600
     action :create
     only_if { node[:coins][:dogecoin][:wallet_s3_secret] != '' }
  end

  remote_file "#{Chef::Config[:file_cache_path]}/dogecoin.tar.gz" do
         source node[:coins][:dogecoin][:source]
         mode "0644"
         backup false
         action :create_if_missing
         notifies :run, 'bash[setup_dogecoin]', :immediately
         notifies :reload, 'service[monit]', :immediately
  end

  bash "setup_dogecoin" do
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

      tar -xzvp --strip-components 1 -f #{Chef::Config[:file_cache_path]}/dogecoin.tar.gz -C #{node[:walletserver][:root]}/build/dogecoin/
      (cd #{node[:walletserver][:root]}/build/dogecoin/src  && make -f #{node[:walletserver][:root]}/build/dogecoin/makefile.dogecoin.unix )

      strip #{node[:walletserver][:root]}/build/dogecoin/src/#{node[:coins][:dogecoin][:executable]}

      mv -f #{node[:walletserver][:root]}/build/dogecoin/src/#{node[:coins][:dogecoin][:executable]} #{node[:walletserver][:root]}/daemons/

    EOH
    action :nothing
  end

