#### Begin prepare system ####
user 'builder' do
  comment 'Builder user'
  home '/home/builder'
  shell '/bin/bash'
  password 'Pas$w0r_d'
end

grant_logon_as_service node['dep_agent_store']['username']
grant_logon_as_service 'builder'

include_recipe 'seven_zip::default'

#### End prepare system ####

set VSTS_URL='https://dev.azure.com/tesco-colleague'
set VSTS_POOL='HRAM Upgrade-INF'
set VSTS_USER=deployer
set VSTS_TOKEN='secret!'
set VSTS_DEPLOYMENT_GROUP_NAME=INF
set VSTS_DEPLOYMENT_GROUP_PROJECT='HRAM Upgrade'

include_recipe 'vsts_agent::default'

dep_agent_name = "win_#{node['hostname']}_dep_agent"

agents_dir = 'C:\\agents'

log 'Test notification' do
  action :nothing
end

# cleanup

vsts_agent dep_agent_name do
  vsts_token node['dep_agent_store']['vsts_token']
  action :remove
end

# Deployment Agent
vsts_agent dep_agent_name do
  deploymentGroup true
  deploymentGroupName node['dep_agent_store']['deployment_group_name']
  projectName node['dep_agent_store']['deployment_group_project']
  deploymentGroupTags 'web, db'
  install_dir "#{agents_dir}\\#{dep_agent_name}"
  user 'builder'
  vsts_url node['dep_agent_store']['vsts_url']
  vsts_pool node['dep_agent_store']['vsts_pool']
  vsts_token node['dep_agent_store']['vsts_token']
  windowslogonaccount 'NT AUTHORITY\\System'
  action :install
end

vsts_agent dep_agent_name do
  action :restart
end
