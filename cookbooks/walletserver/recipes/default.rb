#
# Cookbook Name:: walletserver
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

Log "Preparing build environment"

arch = case node['kernel']['machine']
       when "x86_64" then "amd64"
       when "amd64" then "amd64"
       else "x86"
       end

pversion = node['platform_version'].split('.').first

  case node[:platform]
    when "centos", "redhat"
       package "yum-plugin-fastestmirror" do
         action :install
       end

       node.default['yum']['epel']['enabled'] = true
       include_recipe 'yum-epel'
       %w{gcc-c++ git autoconf automake monit libunwind libunwind-devel zlib-devel tcl tcl-devel nasm boost boost-devel boost-openmpi openmpi-devel leveldb leveldb-devel}.each do |pkg|
         package pkg do
           action :install
         end
       end

    when "ubuntu", "debian"
       package "python-software-properties" do
          action :install
       end

      package "libterm-readkey-perl" do
          action :install
      end

   end


Log "Install Wallet Server..."

  group "#{node[:walletserver][:daemon][:group]}" do
    action :create
  end

  user "#{node[:walletserver][:daemon][:user]}" do
    comment "#{node[:walletserver][:daemon][:user]} daemon"
    gid "#{node[:walletserver][:daemon][:group]}"
    system true
    shell "/bin/false"
    action :create
  end

  directory node[:walletserver][:root] do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

  directory "#{node[:walletserver][:root]}/daemons" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end
  
  directory "#{node[:walletserver][:root]}/build" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

  bash "ldconfig_walletserver" do
   user "root"
   code <<-EOH
      echo "#{node[:walletserver][:root]}/lib" > /etc/ld.so.conf.d/#{node[:walletserver][:root].tr('/','_')}.conf
      ldconfig
    EOH
    action :nothing
  end

  execute "monit_reload" do
      command "monit reload"
      action :nothing
  end
   

