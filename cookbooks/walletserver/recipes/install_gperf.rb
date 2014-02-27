# -*- encoding : utf-8 -*-
#
# Cookbook Name:: gperf
# Recipe:: default
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

log "Install Google Performance Tools into #{node[:walletserver][:root]}"

  directory "#{node[:walletserver][:root]}/build/gperf" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

  remote_file "#{Chef::Config[:file_cache_path]}/gperf.tar.gz" do
         source node[:walletserver][:gperf][:source_file]
         mode "0755"
         backup false
         action :create_if_missing
         notifies :run, 'bash[install_gperf]', :immediately
         notifies :run, 'bash[ldconfig_walletserver]', :immediately
  end

  bash "install_gperf" do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH
      tar -xzvp --strip-components 1 -f #{Chef::Config[:file_cache_path]}/gperf.tar.gz -C #{node[:walletserver][:root]}/build/gperf/
      (cd #{node[:walletserver][:root]}/build/gperf/  && ./configure --prefix=#{node[:walletserver][:root]} && make && make install)
    EOH
    action :nothing
  end

