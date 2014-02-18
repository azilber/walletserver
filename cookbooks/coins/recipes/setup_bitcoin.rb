#
# Cookbook Name:: coins
# Recipe:: bitcoin
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

log "Install #{node into #{node[:walletserver][:root]}"

  include_attribute "coins::bitcoin"

  directory "#{node[:walletserver][:root]}/build/bitcoin" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

  remote_file "#{Chef::Config[:file_cache_path]}/bitcoin.tar.gz" do
         source node[:coins][:bitcoin][:source]
         mode "0755"
         backup false
         action :create_if_missing
         notifies :run, 'bash[install_bitcoin]', :immediately
         notifies :run, 'bash[config_bitcoin]', :immediately
         notifies :run, 'bash[monit_bitcoin]', :immediately
         notifies :run, 'bash[monit_reload]', :immediately
  end

  bash "install_bitcoin" do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH
      export LDFLAGS="-ltcmalloc -lunwind -L#{node[:walletserver][:root]}/lib -L/usr/lib64 -L/usr/local/lib64 -Wl,-rpath #{node[:walletserver][:root]}/lib"

      export CPPFLAGS="-I#{node[:walletserver][:root]}/include -I#{node[:walletserver][:root]}/include/google -I#{node[:walletserver][:root]}/include/leveldb -I#{node[:walletserver][:root]}/include/openssl -I/usr/include"

      tar -xzvp --strip-components 1 -f #{Chef::Config[:file_cache_path]}/bitcoin.tar.gz -C #{node[:walletserver][:root]}/build/bitcoin/
      (cd #{node[:walletserver][:root]}/build/bitcoin  && ./configure --prefix=#{node[:walletserver][:root]} )

     mv #{node[:walletserver][:root]}/src/#{#{node[:coins][:bitcoin][:executable]} #{node[:walletserver][:root]}/daemons/

    EOH
    action :nothing
  end

  bash "config_bitcoin do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH

    EOH
    action :nothing
  end

  bash "monit_bitcoin do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH

    EOH
    action :nothing
  end

