log '=========== Start MapR mapr_configure.rb ============='

mapr_home  = node['sncr_mapr']['home']
mapr_user  = node['sncr_mapr']['user']
mapr_group = node['sncr_mapr']['group']

mapr_cluster_name  = node['sncr_mapr']['clustername']
mapr_cluster_nodes = node['sncr_mapr']['cluster_nodes']

mapr_services = {}
%w( cldb zk rm ws ).each do |cs|
  mapr_services[cs] = node['sncr_mapr'][cs]
end
mapr_services['hs'] = [node['sncr_mapr']['hs']]

mapr_services['sm'] = []
mapr_services['sw'] = []
mapr_services['dw'] = []
mapr_services['os'] = []
mapr_services['oc'] = []

if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else

  # now look for the services that we add via roles

  controller = {
    'sw' => 'mapr_spark_worker',
    'sm' => 'mapr_spark_master',
    'dw' => 'mapr_drill_worker',
    'os' => 'mapr_oozie_server',
    'oc' => 'mapr_oozie_client'
  }

  controller.each do |s, r|
    query = "roles:#{r} AND chef_environment:#{node.chef_environment}"
    search(:node, query).each do |server|
      mapr_services[s].push(server['fqdn'])
    end
  end

end

# create a "deployment-config-file"
inven = {}
mapr_cluster_nodes.each do |name|
  inven[name] = ''
end

mapr_services.each do |s, nodes|
  nodes.each do |name|
    inven[name] = inven[name] + ' ' + s
  end
end

# invert the services into a node inventory
# if that file changes, we need to run configure again

template "#{mapr_home}/conf/sncr-mapr.conf" do
  source 'opt/mapr/conf/sncr-mapr.conf.erb'
  owner mapr_user
  group mapr_group
  mode 00444
  variables(
    cluster_name: mapr_cluster_name,
    cluster_nodes: inven
  )
end

# Make sane list of appropriate nodes...might be a better way to do this...
cldb_nodes = node['sncr_mapr']['cldb'].reject(&:empty?).join(',')
zk_nodes = node['sncr_mapr']['zk'].reject(&:empty?).join(',')
rm_nodes = node['sncr_mapr']['rm'].reject(&:empty?).join(',')

# Run configure.sh to configure the nodes, do NOT bring the cluster up

bash 'Run configure.sh to configure cluster' do
  code <<-EOH

  #{mapr_home}/server/configure.sh \
           -C #{cldb_nodes} \
           -Z #{zk_nodes} \
           -RM #{rm_nodes} \
           -HS #{node['sncr_mapr']['hs']} \
           -D #{node['sncr_mapr']['node']['disks']} \
           -N #{mapr_cluster_name} \
           -no-autostart
  EOH
  not_if { ::File.exist?("#{mapr_home}/conf/disktab") }
  # action :run
end
