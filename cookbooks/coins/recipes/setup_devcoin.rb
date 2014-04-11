# -*- encoding : utf-8 -*-
#
# Cookbook Name:: coins
# Recipe:: setup_devcoin
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

#  include_attribute "coins::devcoin"

log "Install #{node[:coins][:devcoin][:executable]} into #{node[:walletserver][:root]}"


  directory "#{node[:walletserver][:root]}/build/devcoin" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

  template "#{node[:walletserver][:root]}/build/devcoin/makefile.devcoin.unix" do
    source "makefile.devcoin.unix.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0644
  end

log "Configuring #{node[:coins][:devcoin][:executable]} with rpc_allow_net=#{node[:coins][:devcoin][:rpc_allow_net]}, port #{node[:coins][:devcoin][:rpc_port]}"

  template "#{node[:walletserver][:root]}/configs/#{node[:coins][:devcoin][:executable]}.conf" do
    source "coin.conf.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:devcoin][:executable],
       :rpcuser => node[:coins][:devcoin][:rpc_user],
       :rpcpass => node[:coins][:devcoin][:rpc_pass],
       :rpcnet => node[:coins][:devcoin][:rpc_allow_net],
       :rpcport => node[:coins][:devcoin][:rpc_port]
    })
    mode 0600
  end

  template "#{node[:walletserver][:root]}/control/start-#{node[:coins][:devcoin][:executable]}.sh" do
    source "control-start-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:devcoin][:executable]
    })
    mode 0700
  end

  template "#{node[:walletserver][:root]}/control/stop-#{node[:coins][:devcoin][:executable]}.sh" do
    source "control-stop-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:devcoin][:executable],
       :rpcuser => node[:coins][:devcoin][:rpc_user],
       :rpcpass => node[:coins][:devcoin][:rpc_pass]
    })
    mode 0700
  end

  directory "#{node[:walletserver][:root]}/data/#{node[:coins][:devcoin][:executable]}" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0700
    recursive true
  end


  template "/etc/monit.d/devcoin.conf" do
    source "monit_default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:devcoin][:executable],
       :coinuser => node[:walletserver][:daemon][:user],
       :coingroup => node[:walletserver][:daemon][:group],
       :rpchost => "127.0.0.1",
       :rpcport => node[:coins][:devcoin][:rpc_port]
    })
    mode 0600
  end


  s3_file "#{node[:walletserver][:root]}/data/#{node[:coins][:devcoin][:executable]}/wallet.dat" do
     remote_path "/wallet.dat"
     bucket node[:coins][:devcoin][:wallet_s3_bucket]
     aws_access_key_id node[:coins][:devcoin][:wallet_s3_key]
     aws_secret_access_key node[:coins][:devcoin][:wallet_s3_secret]
     owner node[:walletserver][:daemon][:user]
     group node[:walletserver][:daemon][:group]
     mode 0600
     action :create
     only_if { node[:coins][:devcoin][:wallet_s3_secret] != '' }
  end

  remote_file "#{Chef::Config[:file_cache_path]}/devcoin.tar.gz" do
         source node[:coins][:devcoin][:source]
         mode "0644"
         backup false
         action :create_if_missing
         notifies :run, 'bash[setup_devcoin]', :immediately
         notifies :reload, 'service[monit]', :immediately
  end

  bash "setup_devcoin" do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH
      export LDFLAGS="#{node[:walletserver][:ldflags]}"

      export CPPFLAGS="#{node[:walletserver][:cppflags]}"

      tar -xzvp --strip-components 1 -f #{Chef::Config[:file_cache_path]}/devcoin.tar.gz -C #{node[:walletserver][:root]}/build/devcoin/
      (cd #{node[:walletserver][:root]}/build/devcoin/src  && make -f #{node[:walletserver][:root]}/build/devcoin/makefile.devcoin.unix )

      strip #{node[:walletserver][:root]}/build/devcoin/src/#{node[:coins][:devcoin][:executable]}

      mv -f #{node[:walletserver][:root]}/build/devcoin/src/#{node[:coins][:devcoin][:executable]} #{node[:walletserver][:root]}/daemons/

    EOH
    action :nothing
  end

