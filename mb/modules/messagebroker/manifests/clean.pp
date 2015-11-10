define messagebroker::clean ( $mode, $target, $service_code, $version ) {
  if $mode == 'update' {
    exec{
      "Stop_process_${name}":
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/',
        command => "kill -9 `cat ${target}/wso2carbon.pid` ; /bin/echo Killed",
    }
  }
  elsif $mode == 'destroy' {
    exec { "Stop_process_remove_CARBON_HOME_and_pack_${name}":
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/',
        command => "kill -9 `cat ${target}/wso2carbon.pid` ; rm -rf ${target} ; rm -f ${::local_package_dir}/wso2${service_code}-${version}.zip";
    }
  }
}
