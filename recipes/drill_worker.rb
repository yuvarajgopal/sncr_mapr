#
# Cookbook Name:: sncr_mapr
# Recipe:: drill_worker
#
# Copyright (c) 2016 Synchronoss Technologies, Inc., All Rights Reserved.

mapr_homedir = node['sncr_mapr']['home']
mapr_user    = node['sncr_mapr']['user']
mapr_group   = node['sncr_mapr']['group']

drill_direct_memory = node['sncr_mapr']['drill_config']['direct_memory']
drill_heap_size     = node['sncr_mapr']['drill_config']['heap_size']

do_cat = Mixlib::ShellOut.new("cat #{mapr_homedir}/drill/drillversion")
do_cat.run_command

drill_version = do_cat.stdout.chomp
drill_homedir = "#{mapr_homedir}/drill/drill-#{drill_version}"

%w( mapr-drill ).each do |pkg|
  package pkg do
    notifies :run, 'bash[configure for drill]'
  end
end

template "#{drill_homedir}/conf/drill-env.sh" do
  source 'drill/drill-env.sh.erb'
  owner mapr_user
  group mapr_group
  mode 00444
  variables({
              drill_home: drill_homedir,
              direct_memory: drill_direct_memory,
              heap_size: drill_heap_size
            })
  notifies :restart, 'service[mapr-warden]'
end

bash 'configure for drill' do
  action :nothing
  code <<-EOH
    #{mapr_homedir}/server/configure.sh -R
  EOH
  notifies :restart, 'service[mapr-warden]'
end
