#
# Cookbook Name:: bdb
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

  directory "#{node[:walletserver][:root]}/build/bdb" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

  remote_file "#{Chef::Config[:file_cache_path]}/bdb.tar.gz" do
         source node[:walletserver][:bdb][:source_file]
         mode "0755"
         backup false
         action :create_if_missing
         notifies :run, 'bash[install_bdb]', :immediately
         notifies :run, 'bash[ldconfig_walletserver]', :immediately
  end

  bash "install_bdb" do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH
      export LDFLAGS="-ltcmalloc -lunwind -L#{node[:walletserver][:root]}/lib -L/usr/lib64 -L/usr/local/lib64"

      export CPPFLAGS="-I#{node[:walletserver][:root]}/include -I#{node[:walletserver][:root]}/include/boost -I#{node[:walletserver][:root]}/include/google -I#{node[:walletserver][:root]}/include/leveldb -I#{node[:walletserver][:root]}/include/openssl -I/usr/include"

      tar -xzvp --strip-components 1 -f #{Chef::Config[:file_cache_path]}/bdb.tar.gz -C #{node[:walletserver][:root]}/build/bdb/
      (cd #{node[:walletserver][:root]}/build/bdb/build_unix  && ../dist/configure --prefix=#{node[:walletserver][:root]} --enable-cxx --enable-diagnostic --enable-o_direct --enable-stl --enable-test --enable-tcl --with-tcl=/usr/lib64 --enable-umrw --enable-shared && make -j2 && make install)
    EOH
    action :nothing
  end

