# # Cookbook Name:: sncr_mapr
# Recipe:: _make_coresite.xml
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# create the core-site xml from node attributes

require 'mixlib/shellout'

mapr_homedir = node['sncr_mapr']['home']
mapr_user    = node['sncr_mapr']['user']
mapr_group   = node['sncr_mapr']['group']

do_cat = Mixlib::ShellOut.new("cat #{mapr_homedir}/hadoop/hadoopversion")
do_cat.run_command

version = do_cat.stdout.chomp
hadoop_homedir = "#{mapr_homedir}/hadoop/hadoop-#{version}"

# the template should get executed at the end of the run,
# so any properties that were created will get included.

template 'core-site.xml' do
  path "#{hadoop_homedir}/etc/hadoop/core-site.xml"
  source 'hadoop/core-site.xml.erb'
  owner mapr_user
  group mapr_group
  mode 00444
  variables({
              properties: node['sncr_mapr']['coresite_xml']
            })
  notifies :restart, 'service[mapr-warden]'
  action :nothing
end
