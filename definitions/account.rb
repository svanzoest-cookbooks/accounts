# encoding: UTF-8
#
# Cookbook Name: accounts
# Definition: account
#
# Copyright 2009, Alexander van Zoest
#
# define :account, uid: nil,
#                   comment: nil,
#                   group: node['accounts']['default']['group'],
#                   ssh: node['accounts']['default']['do_ssh'],
#                   sudo: node['accounts']['default']['do_sudo'] do
define :account, account_type: 'user',
                 uid: nil,
                 comment: nil,
                 group: 'users',
                 ssh: false,
                 configs: false,
                 sudo: false do
  home_dir = params[:home] || "#{node['accounts']['dir']}/#{params[:name]}"

  user params[:name] do
    comment params[:comment] if params[:comment]
    password params[:password] if params[:password]
    uid params[:uid] if params[:uid]
    gid params[:gid] || params[:group]
    shell params[:shell] || node['accounts']['default']['shell']
    home home_dir
    action :create
  end

  directory home_dir do
    recursive true
    owner params[:name]
    group params[:gid] || params[:group]
    mode 0711
  end

  if params[:ssh]
    remote_directory "#{home_dir}/.ssh" do
      cookbook node['accounts']['cookbook']
      source "#{params[:account_type]}s/#{params[:name]}/ssh"
      files_backup node['accounts']['default']['file_backup']
      files_owner params[:name]
      files_group params[:gid] || params[:group]
      files_mode 0600
      owner params[:name]
      group params[:gid] || params[:group]
      mode '0700'
    end
  end

  if params[:configs]
    remote_directory "#{home_dir}/" do
      cookbook node['accounts']['cookbook']
      source "#{params[:account_type]}s/#{params[:name]}/configs"
      files_backup node['accounts']['default']['file_backup']
      files_owner params[:name]
      files_group params[:gid] || params[:group]
      files_mode 0600
      owner params[:name]
      group params[:gid] || params[:group]
      mode '0700'
    end
  end

  if params[:sudo]
    unless node['accounts']['sudo']['groups'].include?(params[:group])
      unless node['accounts']['sudo']['users'].include?(params[:name])
        a = Array.new(node['accounts']['sudo']['users'])
        a.push(params[:name])
        node.set['accounts']['sudo']['users'] = a
      end
    end
  end
end
