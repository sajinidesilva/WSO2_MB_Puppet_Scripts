define messagebroker::deploy ( $security, $target, $owner, $group, $deployment_code, $mb_profile ) {

  $service = "wso2$mb_profile"

  file {
    "/tmp/${deployment_code}":
      ensure          => present,
      owner           => $owner,
      group           => $group,
      sourceselect    => all,
      ignore          => '.svn',
      recurse         => true,
      source          => [
                          "puppet:///modules/${deployment_code}/configs/",
			  "puppet:///modules/${deployment_code}/patches/",
                          "puppet:///modules/wso2base/configs/",
			  "puppet:///modules/wso2base/patches/",

                        ],
      notify          => Service["${service}"],
  }

  exec {
    "Copy_${name}_modules_to_carbon_home":
      path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/',
      command => "cp -r /tmp/${deployment_code}/* ${target}/; chown -R ${owner}:${group} ${target}/; chmod -R 755 ${target}/",
      require => File["/tmp/${deployment_code}"],
      refreshonly => true,
      subscribe => File["/tmp/${deployment_code}"],
  }

  if $mode == 'destroy' {
	 exec {
			"Remove_${name}_temporory_modules_directory":
      		path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/',
      		command => "rm -rf /tmp/${deployment_code}",
      		require => Exec["Copy_${name}_modules_to_carbon_home"];
	  }
  }
}
