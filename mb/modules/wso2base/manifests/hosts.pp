class hosts{

    file { "/etc/hosts":
        owner   => root,
        group   => root,
        mode    => 775,
        content => template("wso2base/hosts.erb"),
    } 
}
