log "\n=========== Start MapR ssh.rb =============\n"

#######################
# Keys for MapR user

mapr_user  = node['sncr_mapr']['user']
mapr_group = node['sncr_mapr']['group']

directory "/home/#{mapr_user}/.ssh" do
  owner  mapr_user
  group  mapr_group
  mode '700'
end

# cookbook_file "/home/#{mapr_user}/.ssh/authorized_keys" do
#   owner  mapr_user
#   group  mapr_group
#   mode '644'
#   source 'mapr_id_rsa.pub'
# end

cookbook_file "/home/#{mapr_user}/.ssh/id_rsa" do
  owner  mapr_user
  group  mapr_group
  mode '600'
  source 'mapr_id_rsa'
end

cookbook_file "/home/#{mapr_user}/.ssh/id_rsa.pub" do
  owner  mapr_user
  group  mapr_group
  mode '600'
  source 'mapr_id_rsa.pub'
end

cookbook_file "/home/#{mapr_user}/.ssh/config" do
  source 'ssh_config'
  owner  mapr_user
  group  mapr_group
  mode '644'
end
