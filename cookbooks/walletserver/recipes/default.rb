# -*- encoding : utf-8 -*-
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
           only_if { node[:platform_version].to_f >= 6.0 }
        end

       node.default['yum']['epel']['enabled'] = true
       include_recipe 'yum-epel'
       %w{gcc-c++ gcc autoconf automake icu monit zlib-devel bzip2-devel tcl tcl-devel nasm}.each do |pkg|
         package pkg do
           action :install
         end
       end

    when "ubuntu", "debian"
       package "python-software-properties" do
          action :install
       end
      
      %w{libterm-readkey-perl build-essential autoconf automake icu monit libunwind libunwind-devel zlib-devel bzip2-devel tcl tcl-devel nasm}.each do |pkg|
        package pkg do
          action :install
        end
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
    shell "/sbin/nologin"
    supports(manage_home: false)
    action :create
  end

  directory node[:walletserver][:root] do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
    not_if { ::File.directory?(node[:walletserver][:root]) }
  end

  %w{daemons build configs run control data}.each do |cdir|
      directory "#{node[:walletserver][:root]}/#{cdir}" do
         owner node[:walletserver][:daemon][:user]
         group node[:walletserver][:daemon][:group]
         recursive true
         not_if { ::File.directory?("#{node[:walletserver][:root]}/#{cdir}") }
      end
   end

  bash "ldconfig_walletserver" do
   user "root"
   code <<-EOH
      echo "#{node[:walletserver][:root]}/lib" > /etc/ld.so.conf.d/#{node[:walletserver][:root].tr('/','_')}.conf
      ldconfig
    EOH
    action :nothing
  end

  cookbook_file "/etc/monit.d/status.conf" do
    source "monit_status.conf"
    owner "root"
    group node[:walletserver][:daemon][:group]
    mode 0644
    action :create
  end

  service "monit" do
     supports :status => true, :restart => true, :reload => true
     action [ :enable, :start ]
   end

  template "/etc/logrotate.d/coins" do
    source "logrotate-coins.erb"
    owner "root"
    group node[:walletserver][:daemon][:group]
    mode 0644
    action :create
  end
   
node.default[:walletserver][:ldflags] = "-ltcmalloc -lunwind -L#{node[:walletserver][:root]}/lib -L/usr/lib64 -L/usr/local/lib64 -Wl,-rpath #{node[:walletserver][:root]}/lib"
node.default[:walletserver][:cppflags] = "-I#{node[:walletserver][:root]}/include -I#{node[:walletserver][:root]}/include/google -I#{node[:walletserver][:root]}/include/leveldb -I#{node[:walletserver][:root]}/include/openssl -I/usr/include"
