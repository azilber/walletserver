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

#  include_attribute "coins::bitcoin"

log "Install #{node[:coins][:bitcoin][:executable]} into #{node[:walletserver][:root]}"


  directory "#{node[:walletserver][:root]}/build/bitcoin" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

  template "#{node[:walletserver][:root]}/build/bitcoin/makefile.bitcoin.unix" do
    source "makefile.bitcoin.unix.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0644
  end
    

  remote_file "#{Chef::Config[:file_cache_path]}/bitcoin.tar.gz" do
         source node[:coins][:bitcoin][:source]
         mode "0644"
         backup false
         action :create_if_missing
         notifies :run, 'bash[setup_bitcoin]', :immediately
         notifies :run, 'bash[config_bitcoin]', :immediately
         notifies :run, 'bash[monit_bitcoin]', :immediately
         notifies :run, 'execute[monit_reload]', :immediately
  end

  bash "setup_bitcoin" do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH
      export LDFLAGS="#{node[:walletserver][:ldflags]}"

      export CPPFLAGS="#{node[:walletserver][:cppflags]}"

      tar -xzvp --strip-components 1 -f #{Chef::Config[:file_cache_path]}/bitcoin.tar.gz -C #{node[:walletserver][:root]}/build/bitcoin/
      (cd #{node[:walletserver][:root]}/build/bitcoin/src/src  && make -f #{node[:walletserver][:root]}/build/bitcoin/makefile.bitcoin.unix )

      strip #{node[:walletserver][:root]}/build/bitcoin/src/src/#{node[:coins][:bitcoin][:executable]}

      mv -f #{node[:walletserver][:root]}/build/bitcoin/src/src/#{node[:coins][:bitcoin][:executable]} #{node[:walletserver][:root]}/daemons/

    EOH
    action :nothing
  end

  bash "config_bitcoin" do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH

    echo "config btc"
    EOH
    action :nothing
  end

  bash "monit_bitcoin" do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH
    
    echo "monit btc"
    EOH
    action :nothing
  end
