class wso2base::packages {

  $packages = ['lsof','unzip','sysstat','telnet', 'git', 'less', 'tree']

  package { $packages:
    ensure => installed,
  }

}
