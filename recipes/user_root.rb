log "\n=========== Start MapR user_root.rb =============\n"

user 'setting root password' do
  username 'root'
  password node['root']['password']
  action :modify
end
