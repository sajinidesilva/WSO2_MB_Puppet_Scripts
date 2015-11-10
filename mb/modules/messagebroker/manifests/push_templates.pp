define messagebroker::push_templates ( $directory, $target, $mb_profile ) {

  $service = "wso2$mb_profile"

  file { "${target}/repository/${name}":
    ensure  => present,
    owner   => $owner,
    group   => $group,
    mode    => '0755',
    content => template("${directory}/${name}.erb"),
    notify  => Service["${service}"],
  }
}
