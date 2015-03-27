# -*- encoding : utf-8 -*-
#
# Cookbook Name:: coins
# Recipe:: setup_dash
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

#  include_attribute "coins::dash"

log "Install #{node[:coins][:dash][:executable]} into #{node[:walletserver][:root]}"


  directory "#{node[:walletserver][:root]}/build/dash" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

log "Configuring #{node[:coins][:dash][:executable]} with rpc_allow_net=#{node[:coins][:dash][:rpc_allow_net]}, port #{node[:coins][:dash][:rpc_port]}"

  template "#{node[:walletserver][:root]}/configs/#{node[:coins][:dash][:executable]}.conf" do
    source "coin.conf.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:dash][:executable],
       :rpcuser => node[:coins][:dash][:rpc_user],
       :rpcpass => node[:coins][:dash][:rpc_pass],
       :rpcnet => node[:coins][:dash][:rpc_allow_net],
       :rpcport => node[:coins][:dash][:rpc_port]
    })
    mode 0600
  end


  template "#{node[:walletserver][:root]}/control/start-#{node[:coins][:dash][:executable]}.sh" do
    source "control-start-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:dash][:executable]
    })
    mode 0700
  end

  template "#{node[:walletserver][:root]}/control/stop-#{node[:coins][:dash][:executable]}.sh" do
    source "control-stop-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:dash][:executable],
       :rpcuser => node[:coins][:dash][:rpc_user],
       :rpcpass => node[:coins][:dash][:rpc_pass]
    })
    mode 0700
  end

  directory "#{node[:walletserver][:root]}/data/#{node[:coins][:dash][:executable]}" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0700
    recursive true
  end


  template "/etc/monit.d/dash.conf" do
    source "monit_default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:dash][:executable],
       :coinuser => node[:walletserver][:daemon][:user],
       :coingroup => node[:walletserver][:daemon][:group],
       :rpchost => "127.0.0.1",
       :rpcport => node[:coins][:dash][:rpc_port]
    })
    mode 0600
  end


  s3_file "#{node[:walletserver][:root]}/data/#{node[:coins][:dash][:executable]}/wallet.dat" do
     remote_path "/wallet.dat"
     bucket node[:coins][:dash][:wallet_s3_bucket]
     aws_access_key_id node[:coins][:dash][:wallet_s3_key]
     aws_secret_access_key node[:coins][:dash][:wallet_s3_secret]
     owner node[:walletserver][:daemon][:user]
     group node[:walletserver][:daemon][:group]
     mode 0600
     action :create
     only_if { node[:coins][:dash][:wallet_s3_secret] != '' }
  end

  remote_file "#{Chef::Config[:file_cache_path]}/dash.tar.gz" do
         source node[:coins][:dash][:source]
         mode "0644"
         backup false
         action :create_if_missing
         notifies :run, 'bash[setup_dash]', :immediately
         notifies :reload, 'service[monit]', :immediately
  end

  bash "setup_dash" do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH
      export LDFLAGS="#{node[:walletserver][:ldflags]}"
      export CPPFLAGS="#{node[:walletserver][:cppflags]}"
      export PKG_CONFIG_PATH="#{node[:walletserver][:root]}/lib/pkgconfig"

      tar -xzvp --strip-components 1 -f #{Chef::Config[:file_cache_path]}/dash.tar.gz -C #{node[:walletserver][:root]}/build/dash/
      (cd #{node[:walletserver][:root]}/build/dash  && ./autogen.sh && ./configure --prefix=#{node[:walletserver][:root]} --with-boost-libdir=#{node[:walletserver][:root]}/lib --with-boost=#{node[:walletserver][:root]}/include/boost --bindir=#{node[:walletserver][:root]}/daemons --sbindir=#{node[:walletserver][:root]}/daemons --sysconfdir=#{node[:walletserver][:root]}/configs --datadir=#{node[:walletserver][:root]}/data/dash && make -j2 && make install )

      strip #{node[:walletserver][:root]}/daemons/#{node[:coins][:dash][:executable]}
      strip #{node[:walletserver][:root]}/daemons/#{node[:coins][:dash][:client]}

    EOH
    action :nothing
  end

