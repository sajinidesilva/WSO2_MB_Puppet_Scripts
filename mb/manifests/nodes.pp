stage { 'configure': require => Stage['main'] }
stage { 'deploy': require => Stage['configure'] }

node basenode {
  $package_repo       = '/etc/puppet/environments/mb/modules/messagebroker/files/packs'
  $local_package_dir  = '/mnt/packs'
  $deploy_new_packs   = 'true'

  $domain         = 'example.com'
  $hosts_mapping  = [
    "10.100.5.88,puppet",
    "10.100.7.72,mb1"
    ]

    include 'wso2base'
}

node confignode inherits basenode  {

  $packages = ['lsof','unzip','sysstat','telnet', 'git', 'less', 'tree','htop']
  
  $JAVA_HOME = "/usr/lib/jvm/java-7-oracle"


  #Clustering  related configs
   $clustering         = 'true'
   $localmember_port   = '4000' 
   $cluster_nodes     = ["10.100.7.72,4000"]




  # Service subdomains
  $wso2_env_domain      = $domain
  $mb_subdomain         = 'messaging'

  # MySQL server configuration details
  $mysql_port           = '3306'
  $max_connections      = '100000'
  $max_active           = '200'
  $max_wait             = '360000'
  $mysql_driver_file    = 'mysql-connector-java-5.1.26-bin.jar'

  $mysql_server_1       = "mysql1.${domain}"
  $mysql_server_2       = "mysql2.${domain}"




  # Database details
 
   #Password for wso2 H2 database (local registy)
   $carbon_db_password = "wso2carbon"

 
   #Possible values : CQL, HECTOR, RDBMS
   $mb_connector = "CQL" 
  
  $config_database           = [$mysql_server_1,'WSO2MBConfigDB','root','root','config_registry','com.mysql.jdbc.Driver']
  
  # registry databases
   $userstore_database       = [$mysql_server_1,'WSO2MBUserDB','root','root','user_mgt','com.mysql.jdbc.Driver']
   $registry_database        = [$mysql_server_1,'WSO2MBGovernanceDB','root','root','gov_registry', 'com.mysql.jdbc.Driver']
   $mb_database              = [$mysql_server_1,'WSO2MBStoreDB', 'root','root', 'wso2_mb','com.mysql.jdbc.Driver']

 


  # User MGT
  $usrmgt_username        = 'admin'
  $usrmgt_password        = 'admin'
 
 
  ## Keystore information
  $mb_keystore_passwd   = 'wso2carbon'
  $mb_keystore_alias    = 'wso2carbon'
  
  $mb_keystore          = 'repository/resources/security/wso2carbon.jks'
  $mb_truststore_passwd    = 'wso2carbon'
    
  # Cassandra details
  $cassandras           = ["cas1:9160","cas2:9160","cas3:9160"]
  $cluster_name         = "TestCluster"
  $cassandra_username   = "admin" 
  $cassandra_password   = "admin"
  $cassandra_cql_port   = "9042" 
  $cassandra_replication_factor  = "1" 
  $cassandra_read_consistency    = "ONE"
  $cassandra_write_consistency   = "ONE"
 

}


##############################
####### Database Setup #######
##############################

node /mysql/ inherits confignode{
}


##############################
###### Production Setup ######
##############################




node /mb1/ inherits confignode {
  $server_ip= $ipaddress
  $JAVA_HOME = "/home/sasikala/Documents/tools/jdk1.8.0_45"
  class { 'messagebroker':
    version            => '3.0.0',
    offset             => 0,
    maintenance_mode   => true,
    owner              => 'root',
    group              => 'root',
    target             => "/mnt/${ipaddress}",
    stage              => "deploy",
    node_id            => "mb1",
    localmember_port   => $localmember_port,
    cassandras         => $cassandras
  }

}

node /mb2/ inherits confignode {
  $server_ip= $ipaddress

  class { 'messagebroker':
    version            => '3.0.0',
    offset             => 0,
    maintenance_mode   => true,
    owner              => 'ubuntu',
    group              => 'ubuntu',
    target             => "/mnt/${ipaddress}",
    stage              => "deploy",
    node_id            => "mb2",
    localmember_port   => $localmember_port,
    cassandras         => $cassandras
  }

}

#########################################
###### END of the production setup ######
#########################################

