define messagebroker::initialize ( $repo, $version, $service, $deployment_code, $local_dir, $target, $mode, $owner, $group, $mb_profile) {

	#$wso2service = "wso2$mb_profile"

    file { "${local_dir}/wso2${service}-${version}.zip":
    	ensure 	=> present,
    	source 	=> "puppet:///modules/${deployment_code}/packs/wso2${service}-${version}.zip",
        require	=> Exec["creating_local_package_repo_for_${name}",
                          	"creating_target_for_${name}"];
    }

    exec {
        "creating_target_for_${name}":
            path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
            unless    => "test -d ${target}",
            command   => "mkdir -p ${target}";

        "creating_local_package_repo_for_${name}":
            path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/',
            unless    => "test -d ${local_dir}",
            command   => "mkdir -p ${local_dir}";

        "extracting_wso2${service}-${version}.zip_for_${name}":
            path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
            cwd       => $target,
            unless    => "test -d ${target}/wso2${service}-${version}/repository",
            command   => "unzip ${local_dir}/wso2${service}-${version}.zip",
            logoutput => 'on_failure',
            creates   => "${target}/wso2${service}-${version}/repository",
            timeout   => 0,
            require   => File["${local_dir}/wso2${service}-${version}.zip"];

        "setting_permassion_for_${name}":
            path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
            cwd       => $target,
            command   => "chown -R ${owner}:${group} ${target}/wso2${service}-${version} ;
			  chmod -R 755 ${target}/wso2${service}-${version}",
            unless    => "[ -d ${target}/wso2${service}-${version} ] && [ `stat -c %U:%G ${target}/wso2${service}-${version}` = ${owner}:${group} ]",
	    logoutput => 'on_failure',
	    timeout   => 0,
	    require   => Exec["extracting_wso2${service}-${version}.zip_for_${name}"];
    }
}
