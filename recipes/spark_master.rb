#
# Cookbook Name:: sncr_mapr
# Recipe:: spark
#
# Copyright (c) 2016 Synchronoss Technologies, Inc., All Rights Reserved.

# create a spark master node, with spark history server

mapr_user     = node['sncr_mapr']['user']
mapr_group    = node['sncr_mapr']['group']
mapr_homedir  = node['sncr_mapr']['home']

spark_homedir = "#{mapr_homedir}/spark/spark-current"

include_recipe 'sncr_mapr::_spark_common'

bash 'spark fs dirs' do
  code <<-EOH
    hadoop fs -mkdir -p /apps/spark
    hadoop fs -chmod 777 /apps/spark
  EOH
end

%w( mapr-spark-master mapr-spark-historyserver ).each do |pkg|
  package pkg do
    notifies :run, 'bash[configure spark master node]'
  end
end

bash 'configure spark master node' do
  code <<-EOH
    #{mapr_homedir}/server/configure.sh -R
  EOH
  action :nothing
end

# create the slave file

spark_hosts = []
if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  query = "roles:mapr_spark_worker AND chef_environment:#{node.chef_environment}"
  Chef::Log.info("searching for spark nodes nodes with #{query}")
  search(:node, query).each do |server|
    spark_hosts.push(server['hostname'])
  end
end

log 'show spark nodes' do
  message "found spark nodes #{spark_hosts}"
  level :info
end

template "#{spark_homedir}/conf/slaves" do
  source 'spark/slaves.erb'
  owner mapr_user
  group mapr_group
  mode 00644
  variables({
              :workers => spark_hosts
            })
  notifies :run, 'bash[start spark slaves]'
end

bash 'start spark slaves' do
  action :nothing
  code <<-EOH
    su #{mapr_user} -c "#{spark_homedir}/sbin/start-slaves.sh"
  EOH
end
