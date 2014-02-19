#
# Cookbook Name:: walletserver
# Recipe:: install_boost
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

log "Install BOOST Tools into #{node[:walletserver][:root]}"

  directory "#{node[:walletserver][:root]}/build/boost" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

  remote_file "#{Chef::Config[:file_cache_path]}/boost.tar.gz" do
         source node[:walletserver][:boost][:source_file]
         mode "0755"
         backup false
         action :create_if_missing
         notifies :run, 'bash[install_boost]', :immediately
         notifies :run, 'bash[ldconfig_walletserver]', :immediately
  end

  bash "install_boost" do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH
      export LDFLAGS="-ltcmalloc -lunwind -L#{node[:walletserver][:root]}/lib -L/usr/lib64 -L/usr/local/lib64"

      export CPPFLAGS="-I#{node[:walletserver][:root]}/include -I#{node[:walletserver][:root]}/include/boost -I#{node[:walletserver][:root]}/include/google -I#{node[:walletserver][:root]}/include/leveldb -I#{node[:walletserver][:root]}/include/openssl -I/usr/include"

      tar -xzvp --strip-components 1 -f #{Chef::Config[:file_cache_path]}/boost.tar.gz -C #{node[:walletserver][:root]}/build/boost/
#      (cd #{node[:walletserver][:root]}/build/boost  && ./bootstrap.sh --prefix=#{node[:walletserver][:root]} --with-libraries=atomic,chrono,context,coroutine,date_time,exception,filesystem,graph,graph_parallel,iostreams,locale,log,math,mpi,program_options,random,regex,serialization,signals,system,test,thread,timer,wave  && ./b2 install)
      (cd #{node[:walletserver][:root]}/build/boost  && ./bootstrap.sh --prefix=#{node[:walletserver][:root]} --with-libraries=system,filesystem,chrono,program_options,thread,test && ./b2 stage threading=multi link=shared && ./b2 install threading=multi link=shared -—prefix=#{node[:walletserver][:root]})
    EOH
    action :nothing
  end

