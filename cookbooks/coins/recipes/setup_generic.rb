# -*- encoding : utf-8 -*-
#
# Cookbook Name:: coins
# Recipe:: setup_generic
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

#  include_attribute "coins::generic"

log "Install #{node[:coins][:generic][:executable]} into #{node[:walletserver][:root]}"


  directory "#{node[:walletserver][:root]}/build/generic" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

  template "#{node[:walletserver][:root]}/build/generic/makefile.generic.unix" do
    source "makefile.generic.unix.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0644
  end

log "Configuring #{node[:coins][:generic][:executable]} with rpc_allow_net=#{node[:coins][:generic][:rpc_allow_net]}, port #{node[:coins][:generic][:rpc_port]}"

  template "#{node[:walletserver][:root]}/configs/#{node[:coins][:generic][:executable]}.conf" do
    source "coin.conf.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:generic][:executable],
       :rpcuser => node[:coins][:generic][:rpc_user],
       :rpcpass => node[:coins][:generic][:rpc_pass],
       :rpcnet => node[:coins][:generic][:rpc_allow_net],
       :rpcport => node[:coins][:generic][:rpc_port]
    })
    mode 0600
  end


  template "#{node[:walletserver][:root]}/control/start-#{node[:coins][:generic][:executable]}.sh" do
    source "control-start-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:generic][:executable],
       :rpcuser => node[:coins][:generic][:rpc_user],
       :rpcpass => node[:coins][:generic][:rpc_pass],
       :rpcport => node[:coins][:generic][:rpc_port]
    })
    mode 0700
  end

  template "#{node[:walletserver][:root]}/control/stop-#{node[:coins][:generic][:executable]}.sh" do
    source "control-stop-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:generic][:executable],
       :rpcuser => node[:coins][:generic][:rpc_user],
       :rpcpass => node[:coins][:generic][:rpc_pass],
       :rpcport => node[:coins][:generic][:rpc_port]
    })
    mode 0700
  end

  directory "#{node[:walletserver][:root]}/data/#{node[:coins][:generic][:executable]}" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0700
    recursive true
  end


  template "/etc/monit.d/generic.conf" do
    source "monit_default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:generic][:executable],
       :coinuser => node[:walletserver][:daemon][:user],
       :coingroup => node[:walletserver][:daemon][:group],
       :rpchost => "127.0.0.1",
       :rpcport => node[:coins][:generic][:rpc_port]
    })
    mode 0600
  end


  s3_file "#{node[:walletserver][:root]}/data/#{node[:coins][:generic][:executable]}/wallet.dat" do
     remote_path "/wallet.dat"
     bucket node[:coins][:generic][:wallet_s3_bucket]
     aws_access_key_id node[:coins][:generic][:wallet_s3_key]
     aws_secret_access_key node[:coins][:generic][:wallet_s3_secret]
     owner node[:walletserver][:daemon][:user]
     group node[:walletserver][:daemon][:group]
     mode 0600
     action :create
     only_if { node[:coins][:generic][:wallet_s3_secret] != '' }
  end

  remote_file "#{Chef::Config[:file_cache_path]}/generic.tar.gz" do
         source node[:coins][:generic][:source]
         mode "0644"
         backup false
         action :create_if_missing
         notifies :run, 'bash[setup_generic]', :immediately
         notifies :reload, 'service[monit]', :immediately
  end

  bash "setup_generic" do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH
      export LDFLAGS="#{node[:walletserver][:ldflags]}"

      export CPPFLAGS="#{node[:walletserver][:cppflags]}"

      tar -xzvp --strip-components 1 -f #{Chef::Config[:file_cache_path]}/generic.tar.gz -C #{node[:walletserver][:root]}/build/generic/
      (cd #{node[:walletserver][:root]}/build/generic/src/src  && make -f #{node[:walletserver][:root]}/build/generic/makefile.generic.unix )

      strip #{node[:walletserver][:root]}/build/generic/src/src/#{node[:coins][:generic][:executable]}

      mv -f #{node[:walletserver][:root]}/build/generic/src/src/#{node[:coins][:generic][:executable]} #{node[:walletserver][:root]}/daemons/

    EOH
    action :nothing
  end

