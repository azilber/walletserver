# -*- encoding : utf-8 -*-
#
# Cookbook Name:: walletserver
# Recipe:: archive_root
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

Log "Archiving build environment"

  execute "tar_root" do
    cwd "#{node[:walletserver][:root]}/"
    command "tar -cjpf /tmp/wallet_root.tar.bz2 *"
    only_if { ::File.directory?(node[:walletserver][:root]) }
    notifies :run, 'execute[s3_upload]', :immediately
  end

  execute "s3_upload" do
    cwd '/tmp/'
    command "s3cmd put /tmp/wallet_root.tar.bz2 s3://#{node[:walletserver][:s3_bucket]}/"
    only_if { node[:s3cmd][:aws_access_key_id] != '' }
    action :nothing
  end
