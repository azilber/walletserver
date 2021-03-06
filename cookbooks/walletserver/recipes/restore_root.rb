# -*- encoding : utf-8 -*-
#
# Cookbook Name:: walletserver
# Recipe:: restore_root
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

Log "UnArchiving build environment"

  execute "s3_download" do
    cwd '/tmp/'
    command "s3cmd get s3://#{node[:walletserver][:s3_bucket]}/wallet_root.tar.bz2 /tmp/"
    only_if { node[:s3cmd][:aws_access_key_id] != '' }
    notifies :run, 'execute[untar_root]', :immediately
    notifies :run, 'bash[ldconfig_walletserver]', :immediately
  end

 execute "untar_root" do
    cwd '/tmp/'
    command "tar -xjpf /tmp/wallet_root.tar.bz2 -C #{node[:walletserver][:root]}/"
    only_if { ::File.directory?(node[:walletserver][:root]) }
    action :nothing
  end
