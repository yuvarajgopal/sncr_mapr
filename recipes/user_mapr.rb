log "\n=========== Start MapR user_mapr.rb =============\n"

data_bag   = node['sncr_mapr']['users_data_bag']
mapr_user  = node['sncr_mapr']['user']
mapr_group = node['sncr_mapr']['group']
mapr_gid   = node['sncr_mapr']['gid']

users_manage mapr_group do
  group_id mapr_gid
  action [:create]
  data_bag data_bag
  manage_nfs_home_dirs false
  not_if { data_bag.nil? }
end

sudo 'mapr' do
  user 'mapr'
  runas 'ALL'
  nopasswd true
end

# assume typical /home
# should really use getent
mapr_homedir = "/home/#{mapr_user}"

cookbook_file "#{mapr_homedir}/.bashrc" do
  source 'mapr_dot-bashrc'
  owner mapr_user
  group mapr_group
  mode 00644
end

directory "#{mapr_homedir}/.bashrc.d" do
  owner mapr_user
  group mapr_group
  mode 00755
end
