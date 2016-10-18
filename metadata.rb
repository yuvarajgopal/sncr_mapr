name             'sncr_mapr'
maintainer       'stephen.corbesero@synchronoss.com'
maintainer_email ''
license          'All rights reserved'
description      'Installs/Configures mapr'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.13.3'

%w( build-essential iptables java limits line ntp
    sysctl selinux sudo users yum ).each do |cb|
  depends cb
end

%w( centos redhat ).each do |os|
  supports os
end
