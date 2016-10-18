default['sncr_mapr']['users_data_bag'] = 'users'
default['sncr_mapr']['uid'] = 5000
default['sncr_mapr']['gid'] = 5000
default['sncr_mapr']['user'] = 'mapr'
default['sncr_mapr']['group'] = 'mapr'
default['sncr_mapr']['cloudplatform'] = 'aws'

default['sncr_mapr']['manage_java'] = true

# All MapR nodes in this cluster
default['sncr_mapr']['cluster_nodes'] = []

# Enter total number of nodes in MapR cluster here
default['sncr_mapr']['node_count'] = '3'

# Define MapR roles for configure.sh here
default['sncr_mapr']['cldb'] = []
default['sncr_mapr']['zk'] = []
default['sncr_mapr']['rm'] = []
default['sncr_mapr']['hs'] = 'ip-172-16-2-245.ec2.internal'
default['sncr_mapr']['ws'] = []

default['sncr_mapr']['home'] = '/opt/mapr'
default['sncr_mapr']['clustername'] = 'chef_test_cluster'
default['sncr_mapr']['version'] = '4.0.2'
default['sncr_mapr']['repo_url'] = 'http://package.mapr.com/releases'

default['sncr_mapr']['node']['disks'] = '/dev/xvdf,/dev/xvdg'

default['sncr_mapr']['yum']['gpgkey_url'] =
  'http://package.mapr.com/releases/pub/maprgpg.key'

default['sncr_mapr']['clustershell']['rpm_url'] =
  'https://github.com/downloads/cea-hpc/clustershell/clustershell-1.6-1.el6.noarch.rpm'

default['sncr_mapr']['spark_config']['daemon_memory'] = '1g'
default['sncr_mapr']['spark_config']['worker_memory'] = '8g'

default['sncr_mapr']['drill_config']['direct_memory'] = '8G'
default['sncr_mapr']['drill_config']['heap_size'] = '4G'

case node['platform_family']
when 'rhel'
  default['sncr_mapr']['prereq']['packages'] = %w(
    bash dmidecode dstat git hdparm
    initscripts iputils irqbalance
    lsof nc nfs-utils nfs-utils-lib patch
    redhat-lsb-core rpcbind rpm-libs sdparm
    shadow-utils syslinux unzip wget zip )
end
