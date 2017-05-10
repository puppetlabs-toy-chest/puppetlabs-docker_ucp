# == Class: docker_ucp
#
# Installs or removes the Docker Universal Control Plane application using
# the official UCP installer.
#
# === Parameters
#
# [*ensure*]
#   Whether to install or uninstall Docker UCP. Defaults to present.
#   Valid values are present or absent.
#
# [*controller*]
#   Whether to install the controller or a normal UCP node.
#   Defaults to false.
#
# [*subject_alternative_names*]
#   An array of additional Subject Alternative Names for certificates.
#
# [*host_address*]
#   Specify the visible IP/hostname for this node (override automatic detection).
#
# [*swarm_port*]
#   Select what port to run the local Swarm manager on.
#
# [*controller_port*]
#   Select what port to run the local Controller on.
#
# [*dns_servers*]
#   Set custom DNS servers for the UCP infrastructure containers.
#
# [*dns_options*]
#   Set DNS options for the UCP infrastructure containers.
#
# [*dns_search_domains*]
#   Set custom DNS search domains for the UCP infrastructure containers.
#
# [*tracking*]
#		Whether or not to allow UCP to collect anonymous tracking and analytics information.
# 	Defaults to true
#
# [*usage*]
#		Whether or not to allow UCP to collect anonymous usage information.
#		Defaults to true
#
# [*version*]
#		Specify a specific UCP version.
#
# [*external_ca*]
#		Set up UCP with an external CA.
#
# [*preserve_certs*]
#   Whether or not to (re)generate certs on the host if existing ones are found.
#   Defaults to false.
#
# [*swarm_scheduler*]
#   Specify a specific Swarm scheduler. Valid values are spead, binpack or random.
#
# [*ucp_url*]
#   The HTTPS URL for the UCP controller, used by nodes to join the cluster.
#   Required for nodes.
#
# [*ucp_manager*]
#   The ip address of the UCP manager.
#   Only required if you are using UCP 2.0 and above
#
# [*ucp_id*]
#   The ID for the UCP. Used when deleting UCP with ensure => absent.
#
# [*fingerprint*]
#   The certificate fingerprint for the UCP controller.
#   Required for nodes.
#
# [*token*]
#  This is the authtentication token used for UCP 2.0 and above
#  Required only if you are using UCP version 2.0 or higher
#
# [*replica*]
#   Whether or not this is a replica of the controller. Defaults to false.
#   Only applicable for nodes.
#
# [*username*]
#   A username to authenticate a node with the UCP controller.
#   Required for nodes.
#
# [*password*]
#   The password used to authenticate a node with the UCP controller.
#   Required for nodes.
#
# [*license_file*]
#   A path to a valid Docker UCP license file. You can set this as part of installation
#   or upload via the web interface at a later date.
#
# [*local_client*]
#   Whether or not the Docker client is local or using Swarm. Defaults to false.
#   This is y useful in some testing and bootstrapping scenarios.
#
class docker_ucp (
  $ensure = $docker_ucp::params::ensure,
  $controller = $docker_ucp::params::controller,
  $host_address = $docker_ucp::params::host_address,
  $swarm_port = $docker_ucp::params::swarm_port,
  $controller_port = $docker_ucp::params::controller_port,
  $dns_servers = $docker_ucp::params::dns_servers,
  $dns_options = $docker_ucp::params::dns_options,
  $dns_search_domains = $docker_ucp::params::dns_search_domains,
  $tracking = $docker_ucp::params::tracking,
  $usage = $docker_ucp::params::usage,
  $version = $docker_ucp::params::version,
  $docker_socket_path = $docker_ucp::params::docker_socket_path,
  $extra_parameters = $docker_ucp::params::extra_parameters,
  $subject_alternative_names = $docker_ucp::params::subject_alternative_names,
  $external_ca = $docker_ucp::params::external_ca,
  $preserve_certs = $docker_ucp::params::preserve_certs,
  $swarm_scheduler = $docker_ucp::params::swarm_scheduler,
  $preserve_certs_on_delete = $docker_ucp::params::preserve_certs,
  $preserve_images_on_delete = $docker_ucp::params::preserve_images_on_delete,
  $ucp_url = $docker_ucp::params::ucp_url,
  $ucp_manager = $docker_ucp::params::ucp_manager,
  $ucp_id = $docker_ucp::params::ucp_id,
  $fingerprint = $docker_ucp::params::fingerprint,
  $token = $docker_ucp::params::token,
  $listen_address = $docker_ucp::params::listen_address,
  $advertise_address = $docker_ucp::params::advertise_address,
  $replica = $docker_ucp::params::replica,
  $username = $docker_ucp::params::username,
  $password = $docker_ucp::params::password,
  $license_file = $docker_ucp::params::license_file,
  $local_client = $docker_ucp::params::local_client,
  $dtr_external_url = $docker_ucp::params::dtr_external_url,
  $ucp_node = $docker_ucp::params::ucp_node,
  $ucp_username = $docker_ucp::params::ucp_username,
  $ucp_password = $docker_ucp::params::ucp_password,
  $ucp_insecure_tls = $docker_ucp::params::ucp_insecure_tls,

) inherits docker_ucp::params {

  validate_re($::osfamily, '^(Debian|RedHat)$', "${::operatingsystem} not supported. This module only works on Debian and Red Hat based systems.") # lint:ignore:140chars

  validate_re($ensure, '^(present|absent)$')
  validate_bool($tracking, $usage, $preserve_certs, $preserve_certs_on_delete, $preserve_images_on_delete, $controller, $external_ca, $replica) # lint:ignore:140chars
  validate_absolute_path($docker_socket_path)
  validate_string($host_address, $version, $ucp_url, $ucp_id, $fingerprint, $username, $password) # lint:ignore:140chars

  if $swarm_port {
    validate_integer($swarm_port)
  }
  if $controller_port {
    validate_integer($controller_port)
  }
  if $swarm_scheduler {
    validate_re($swarm_scheduler, '^(spread|binpack|random)$')
  }

  if $license_file {
    validate_absolute_path($license_file)
  }

  if ($ensure == 'absent') {
    if !$ucp_id {
      fail('When passing ensure => absent you must also provide the UCP id.')
    }
  } else {
    if !$controller {
      if !$ucp_url {
        fail('When joining UCP you must provide a URL.')
      }
      if !$fingerprint {
        fail('When joining UCP you must provide a fingerprint.')
      }
    }
  }

  Exec {
    path      => ['/usr/bin', '/bin'],
    logoutput => true,
    tries     => 3,
    try_sleep => 5,
  }

  if $local_client {
    $install_unless = 'docker inspect ucp-controller'
    $join_unless = 'docker inspect ucp-proxy'
  } else {
    $install_unless = "docker inspect ${::hostname}/ucp-controller"
    $join_unless = "docker inspect ${::hostname}/ucp-proxy"
  }

  if $ensure == 'absent' {
    $uninstall_flags = ucp_uninstall_flags({
      ucp_id                    => $ucp_id,
      preserve_certs_on_delete  => $preserve_certs_on_delete,
      preserve_images_on_delete => $preserve_images_on_delete,
      extra_parameters          => any2array($extra_parameters),
    })
    exec { 'Uninstall Docker Universal Control Plane':
      command => "docker run --rm -v ${docker_socket_path}:/var/run/docker.sock --name ucp docker/ucp uninstall ${uninstall_flags}",
      onlyif  => $join_unless,
    }
  } else {
    if $controller {
      $install_flags = ucp_install_flags({
        admin_username     => $username,
        admin_password     => $password,
        host_address       => $host_address,
        tracking           => $tracking,
        usage              => $usage,
        version            => $version,
        swarm_port         => $swarm_port,
        controller_port    => $controller_port,
        preserve_certs     => $preserve_certs,
        external_ca        => $external_ca,
        swarm_scheduler    => $swarm_scheduler,
        dns_servers        => any2array($dns_servers),
        dns_options        => any2array($dns_options),
        dns_search_domains => any2array($dns_search_domains),
        san                => any2array($subject_alternative_names),
        extra_parameters   => any2array($extra_parameters),
      })
      if $license_file {
        exec { 'Install Docker Universal Control Plane':
          command => "docker run --rm -v ${docker_socket_path}:/var/run/docker.sock -v ${license_file}:/docker_subscription.lic --name ucp docker/ucp install ${install_flags}", # lint:ignore:140chars
          unless  => $install_unless,
        }
      } else {
        exec { 'Install Docker Universal Control Plane':
          command => "docker run --rm -v ${docker_socket_path}:/var/run/docker.sock --name ucp docker/ucp install ${install_flags}",
          unless  => $install_unless,
        }
      }
    } else {
      $join_flags = ucp_join_flags({
        host_address       => $host_address,
        tracking           => $tracking,
        usage              => $usage,
        version            => $version,
        fingerprint        => $fingerprint,
        ucp_url            => $ucp_url,
        replica            => $replica,
        dns_servers        => any2array($dns_servers),
        dns_options        => any2array($dns_options),
        dns_search_domains => any2array($dns_search_domains),
        san                => any2array($subject_alternative_names),
        extra_parameters   => any2array($extra_parameters),
      })

      if $version =~ /^2.*/ {
        exec { 'Join Docker Universal Control Plane v2':
          command => "docker swarm join --listen-addr ${listen_address} --advertise-addr ${advertise_address}:2377  --token ${token} ${ucp_manager}:2377", # lint:ignore:140chars
          unless  => $join_unless,
          }
      }

      else {
        exec { 'Join Docker Universal Control Plane v1':
          command => "docker run --rm -v ${docker_socket_path}:/var/run/docker.sock -e 'UCP_ADMIN_USER=${username}' -e 'UCP_ADMIN_PASSWORD=${password}' --name ucp docker/ucp join ${join_flags}", # lint:ignore:140chars
          unless  => $join_unless,
        }
      }
    }
  }
}
