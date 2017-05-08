# == Define: docker_ucp::dtr
#
#  A define type that managers Docker's trusted registry 
#
# === Parameters
#
# [*install*]
#   This is a boolean to flag a new install of a DTR.
#   If set to true, Puppet will attempt to set up a new DTR
#   Defaults to false
# 
# [*join*]
#   This resource is set to true when adding a replica to your DTR.
#   NOTE join and install can not be used at the same time.
#   Defaults to false
#
# [*dtr_version*] 
#   The version of DTR you want installed. This resource must be set.
#   If you are unsure of the version you can set latest to test.
#   Defaults to undef 
#
# [*dtr_external_url*]
#   The external URL that is used to access your Docker Trusted Registry
#   Required if dtr => true
# 
# [*ucp_node*]
#   The UCP node which the Docker trusted Registry will run on.
#   Required if dtr => true
#
# [*ucp_username*]
#   The admin user name for the UCP cluster
#   Required if dtr => true
# 
# [*ucp_password*]
#   The admin password for the UCP cluster
#   Required if dtr => true
#
# [*ucp_insecure_tls*]
#   A boolean flag to check if the certificate the UCP cluster in vaild. Set this to true
#   if you are using a self signed certificate
#   Defaults to false
#
# [*dtr_ucp_url*]
#   This the URL that the DTR will use to communicate with the UCP cluster
#    Defaults to undef
#
# [*replica_id*]
#  The replica ID for the DTR cluster
#  Defaults to undef
#  
# [*ucp_ca*]
#  The ca to pass as part of the intall/join flags
#  Defaults to undef 
#

define docker_ucp::dtr (

  $ensure = present,
  $install = false,
  $join = false,
  $dtr_version = undef,
  $dtr_external_url = undef,
  $ucp_node = undef,
  $ucp_username = undef,
  $ucp_password = undef,
  $ucp_insecure_tls = false,
  $dtr_ucp_url = undef,
  $dtr_existing_replica_id = undef,
  $replica_id = undef,
  $ucp_ca = undef,
  ) {

  validate_re($ensure, '^(present|absent)$')
  validate_string($dtr_version, $dtr_external_url, $ucp_node, $ucp_username, $ucp_password, $dtr_existing_replica_id)
  validate_bool($install, $ucp_insecure_tls)

  if $install {

  $dtr_install_flags = dtr_install_flags({
    dtr_version => $dtr_version,
    dtr_external_url => $dtr_external_url,
    ucp_node => $ucp_node,
    ucp_username => $ucp_username,
    ucp_password => $ucp_password,
    ucp_insecure_tls => $ucp_insecure_tls,
    dtr_ucp_url => $dtr_ucp_url,
    replica_id => $replica_id,
    ucp_ca => $ucp_ca,
    })

  $docker_install_command = "docker run -t --rm docker/dtr:${dtr_version} install"

  $exec_install = "${docker_install_command} ${dtr_install_flags}"
  $exec_unless = 'docker ps | grep dtr-api'

  exec { 'Install dtr':
    command     => $exec_install,
    environment => 'HOME=/root',
    path        => ['/bin', '/usr/bin'],
    timeout     => 0,
    unless      => $exec_unless,
    }
  }

  if $join {

  $dtr_join_flags = dtr_join_flags({
    dtr_version => $dtr_version,
    dtr_external_url => $dtr_external_url,
    ucp_node => $ucp_node,
    ucp_username => $ucp_username,
    ucp_password => $ucp_password,
    ucp_insecure_tls => $ucp_insecure_tls,
    dtr_ucp_url => $dtr_ucp_url,
    dtr_existing_replica_id => $dtr_existing_replica_id,
    replica_id => $replica_id,
    ucp_ca => $ucp_ca,
    })

  $docker_join_command = "docker run -t --rm docker/dtr:${dtr_version} join"

  $exec_join = "${docker_join_command} ${dtr_join_flags}"
  $exec_join_onlyif = 'docker ps | grep dtr-api'

  exec { 'Join dtr':
    command     => $exec_join,
    environment => 'HOME=/root',
    path        => ['/bin', '/usr/bin'],
    timeout     => 0,
    onlyif      => $exec_join_onlyif,
    }
  }

  if $ensure == 'absent' {

  $dtr_uninstall_flags = dtr_install_flags({
    dtr_version => $dtr_version,
    dtr_external_url => $dtr_external_url,
    ucp_node => $ucp_node,
    ucp_username => $ucp_username,
    ucp_password => $ucp_password,
    ucp_insecure_tls => $ucp_insecure_tls,
    dtr_ucp_url => $dtr_ucp_url,
    replica_id => $replica_id,
    ucp_ca => $ucp_ca,
    })

  $exec_onlyif = 'docker ps | grep dtr-api'

  $docker_uninstall_command = "docker run -t --rm docker/dtr:${dtr_version} destroy ${dtr_uninstall_flags}"

  exec { 'Uninstall dtr':
    command     => $docker_uninstall_command,
    environment => 'HOME=/root',
    path        => ['/bin', '/usr/bin'],
    onlyif      => $exec_onlyif,
    }
  }
}
