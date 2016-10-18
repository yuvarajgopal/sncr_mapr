log "\n=========== Start MapR mapr_start_warden.rb =============\n"

service 'mapr-warden' do
  action [:start]
end
