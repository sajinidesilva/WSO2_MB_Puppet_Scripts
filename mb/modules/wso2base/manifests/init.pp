class wso2base{
  include hosts
#  include users
#  include packages
#
#  file { '/etc/environment':
#    ensure => present,
#    source => 'puppet:///modules/wso2base/environment',
#  }

  cron { 'ntpdate':
    command => "/usr/sbin/ntpdate pool.ntp.org",
    user    => root,
    minute  => '*/50'
  }


}
