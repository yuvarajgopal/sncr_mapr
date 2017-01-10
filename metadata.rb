name             'sncr_mapr'
maintainer       'yuvaraj.gopal@synchronoss.com'
maintainer_email ''
license          'All rights reserved'
description      'Installs/Configures mapr'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.2'

%w( java sudo users yum ).each do |cb|
  depends cb
end

%w( centos redhat ).each do |os|
  supports os
end
