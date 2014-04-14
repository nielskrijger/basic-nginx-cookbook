#
# Create user and group
#

group node['nginx']['group'] do
  system true
  gid node['nginx']['gid']
end

user node['nginx']['user'] do
  group node['nginx']['group']
  home node['nginx']['homedir']
  system true
  action :create
  manage_home true
  uid node['nginx']['uid']
end

group node['nginx']['conf']['worker_group'] do
  system true
end

user node['nginx']['conf']['worker_user'] do
  group node['nginx']['conf']['worker_group']
  home node['nginx']['conf']['worker_homedir']
  system true
  action :create
  manage_home true
end

#
# Install NGINX from repo
#

template '/etc/yum.repos.d/nginx.repo' do
  mode '0644'
  source 'nginx.repo.erb'
end

package 'nginx'

#
# Create directories
#

directories = [File.dirname(node['nginx']['conf']['error_log']),
               File.dirname(node['nginx']['conf_file']),
               node['nginx']['conf']['conf.d'],
               node['nginx']['conf']['sites_enabled']]
directories.each do |dir|
  directory dir do
    action :create
    recursive true
    owner node['nginx']['user']
    group node['nginx']['group']
    mode '0755'
  end
end

file node['nginx']['conf']['error_log'] do
  owner node['nginx']['user']
  group node['nginx']['group']
  mode '0644'
  action :create_if_missing
end

#
# Create Nginx configuration
#

template '/etc/init/nginx.conf' do
  mode '0644'
  source 'init.nginx.conf.erb'
end

template node['nginx']['conf_file'] do
  mode '0644'
  owner node['nginx']['user']
  group node['nginx']['group']
  source 'nginx.conf.erb'
end

service 'nginx' do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end