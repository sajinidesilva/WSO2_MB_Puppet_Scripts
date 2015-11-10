class messagebroker (
    $version,
    $offset=0,
    $members=undef,
    $replicationfactor=1,
    $mb_subdomain='mb',
    $cluster_name='Test Cluster',
    $cassandras=[],
    $localmember_port=4100,
    $config_db=governance,
    $maintenance_mode=true,
    $depsync=false,
    $sub_cluster_domain=mgt,
    $owner=root,
    $group=root,
    $clustering='true',
    $target="/mnt",
    $node_id="default",
) inherits params {

    $mb_profile			= false
    $deployment_code	= "messagebroker"
    $service_code       = "mb"
    $carbon_home        = "${target}/wso2${service_code}-${version}"

    $service_templates 	= [
       "conf/carbon.xml",
       "conf/axis2/axis2.xml",
       "conf/broker.xml",
       #"conf/tomcat/catalina-server.xml",
       "conf/datasources/mb-datasources.xml",
    ]

    $common_templates = [
       "conf/user-mgt.xml",
       "conf/registry.xml",
       "conf/datasources/master-datasources.xml",
    ]

    tag ('messagebroker')

    if versioncmp($version, '3.0.0') < 0 {
        warning ("Version ${version} is not compatible with this module")
    }

    clean { $deployment_code:
        mode         => $maintenance_mode,
        target       => $carbon_home,
        service_code => $service_code,
        version      => $version,
    }

    initialize { $deployment_code:
        repo      => $package_repo,
        version   => $version,
        mode      => $maintenance_mode,
        service   => $service_code,
        deployment_code => $deployment_code,
        local_dir => $local_package_dir,
        owner     => $owner,
        group     => $group,
        target    => $target,
	      mb_profile      => "mb",
        require   => Clean[$deployment_code],
    }

    deploy { $deployment_code:
        security        => true,
        owner           => $owner,
        group           => $group,
        target          => $carbon_home,
        deployment_code => $deployment_code,
	mb_profile      => "mb",
        require         => Initialize[$deployment_code],
    }

    push_templates {
        $service_templates:
	    	mb_profile => "mb",
            target     => $carbon_home,
            directory  => $deployment_code,
            require    => Deploy[$deployment_code];

        $common_templates:
	    	mb_profile => "mb",
            target     => $carbon_home,
            directory  => "wso2base",
            require    => Deploy[$deployment_code];
    }

    file { "${carbon_home}/bin/wso2server.sh":
        ensure  => present,
        owner   => $owner,
        group   => $group,
        mode    => '0755',
        content => template("${deployment_code}/wso2server.sh.erb"),
        require => Deploy[$deployment_code],
        notify  => Service["wso2mb"],
    }

    file {
        "/etc/init.d/wso2mb":
            ensure  => present,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            content => template("${deployment_code}/wso2mb.erb"),
            require => Deploy[$deployment_code],
    }

    service {
        "wso2mb":
            ensure      => stopped,
            enable      => true,
            hasstatus   => true,
            hasrestart  => true,
            require     => [
                        Initialize[$deployment_code],
                        Deploy[$deployment_code],
                        Push_templates[$service_templates],
                        File["/etc/init.d/wso2mb"],
                        File["${carbon_home}/bin/wso2server.sh"],
                    ],
                }
}
