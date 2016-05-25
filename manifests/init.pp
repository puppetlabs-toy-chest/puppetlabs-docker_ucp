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
# [*ucp_id*]
#   The ID for the UCP. Used when deleting UCP with ensure => absent.
#
# [*fingerprint*]
#   The certificate fingerprint for the UCP controller.
#   Required for nodes.
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
class docker_ucp(
  $ensure = 'present',
  $controller = false,
  $host_address = undef,
  $swarm_port = undef,
  $controller_port = undef,
  $dns_servers = [],
  $dns_options = [],
  $dns_search_domains = [],
  $tracking = true,
  $usage = true,
  $version = undef,
  $docker_socket_path = '/var/run/docker.sock',
  $extra_parameters = undef,
  $subject_alternative_names = [],
  $external_ca = false,
  $preserve_certs = false,
  $swarm_scheduler = undef,
  $preserve_certs_on_delete = false,
  $preserve_images_on_delete = false,
  $ucp_url = undef,
  $ucp_id = undef,
  $fingerprint = undef,
  $replica = false,
  $username = 'admin',
  $password = 'orca',
  $license_file = undef,
) {
  validate_re($::osfamily, '^(Debian|RedHat)$', "${::operatingsystem} not supported. This module only works on Debian and Red Hat based systems.")

  validate_re($ensure, '^(present|absent)$')
  validate_bool($tracking, $usage, $preserve_certs, $preserve_certs_on_delete, $preserve_images_on_delete, $controller, $external_ca, $replica)
  validate_absolute_path($docker_socket_path)
  validate_string($host_address, $version, $ucp_url, $ucp_id, $fingerprint, $username, $password)

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

  if $ensure == 'absent' {
    $uninstall_flags = ucp_uninstall_flags({
      ucp_id                    => $ucp_id,
      preserve_certs_on_delete  => $preserve_certs_on_delete,
      preserve_images_on_delete => $preserve_images_on_delete,
      extra_parameters          => any2array($extra_parameters),
    })
    exec { 'Uninstall Docker Universal Control Plane':
      command => "docker run --rm -v ${docker_socket_path}:/var/run/docker.sock --name ucp docker/ucp uninstall ${uninstall_flags}",
      onlyif  => 'docker inspect ucp-proxy',
    }
  } else {
    if $controller {
      $install_flags = ucp_install_flags({
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
          command => "docker run --rm -v ${docker_socket_path}:/var/run/docker.sock -v ${license_file}:/docker_subscription.lic --name ucp docker/ucp install ${install_flags}",
          unless  => 'docker inspect ucp-controller',
        }
      } else {
        exec { 'Install Docker Universal Control Plane':
          command => "docker run --rm -v ${docker_socket_path}:/var/run/docker.sock --name ucp docker/ucp install ${install_flags}",
          unless  => "docker inspect ${::hostname}/ucp-controller",
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
      exec { 'Join Docker Universal Control Plane':
        command => "docker run --rm -v ${docker_socket_path}:/var/run/docker.sock -e 'UCP_ADMIN_USER=${username}' -e 'UCP_ADMIN_PASSWORD=${password}' --name ucp docker/ucp join --replica ${join_flags}",
        unless  => "docker inspect ${::hostname}/ucp-proxy",
      }
    }
  }
}
