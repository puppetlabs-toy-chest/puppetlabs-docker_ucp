# docker_ucp

[![Puppet
Forge](http://img.shields.io/puppetforge/v/puppetlabs/docker_ucp.svg)](https://forge.puppetlabs.com/puppetlabs/docker_ucp)
[![Build
Status](https://travis-ci.org/puppetlabs/puppetlabs-docker_ucp.svg?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-docker_ucp)

1.  [Description - What the module does and why it is useful](#description)
2.  [Setup - The basics of getting started with docker_ucp](#setup)
    -  [Beginning with docker_ucp](#beginning-with-docker-ucp)
3.  [Usage - Configuration options and additional functionality](#usage)
4.  [Limitations - OS compatibility, etc.](#limitations)
5.  [Development - Guide for contributing to the module](#development)

## Description

The [Docker Universal Control
Plane](https://www.docker.com/products/docker-universal-control-plane) (UCP)
module installs and configures a UCP controller, and joins nodes to it.

This module provides a single class, `docker_ucp`, which uses the
official [`docker/ucp` container](https://hub.docker.com/r/docker/ucp/) to
bootstrap a UCP controller or join a node to an existing UCP-managed swarm.

## Setup

The module depends on Docker. To install and configure Docker with Puppet, use
the [`garethr/docker` module](https://forge.puppet.com/garethr/docker).

Review the
[UCP system requirements](https://docs.docker.com/datacenter/ucp/2.1/guides/admin/install/system-requirements/)
before installing a UCP controller on a node, and
[plan your UCP installation](https://docs.docker.com/datacenter/ucp/2.1/guides/admin/install/plan-installation/)
before deploying UCP in a production environment.

### Beginning with docker_ucp

The `docker_ucp` class has two modes of operation: to install and configure a
UCP controller on a node, and to join a node to a UCP-managed swarm.

#### Installing a controller

To install a UCP controller with the default `admin/orca` username and password,
add the `docker_ucp` class with the `controller` parameter set to true.

```puppet
class { 'docker_ucp':
  controller => true,
}
```

Once the controller is installed and available, log into it and change the admin user
password.

#### Joining a node

You can also use the `docker_ucp` class to join a node to a UCP-managed swarm.
The required class parameters depend on your UCP version. See
[Joining a node to a UCP-managed swarm](#joining-a-node-to-a-UCP-managed-swarm)
for examples.

## Usage

The class takes a number of parameters, depending on your specific
setup. Consult the UCP documentation for details of this options.

```puppet
class { 'docker_ucp':
  controller                => true,
  host_address              => ::ipaddress_eth1,
  version                   => '1.0.0',
  usage                     => false,
  tracking                  => false,
  subject_alternative_names => ::ipaddress_eth1,
  external_ca               => false,
  swarm_scheduler           => 'binpack',
  swarm_port                => 19001,
  controller_port           => 19002,
  preserve_certs            => true,
  docker_socket_path        => '/var/run/docker.sock',
  license_file              => '/etc/docker/subscription.lic',
}
```

Note that `license_file` option will only work with versions of UCP
later than 0.8.0.

### Joining a node to a UCP-managed swarm

#### Version =< 1

```puppet
class { 'docker_ucp':
  ucp_url     => 'https://ucp-controller.example.com',
  fingerprint => 'the-ucp-fingerprint-for-your-install',
}
```

The module uses the default username and password. To set these, provide those in
parameters.

The class also takes a number of
other parameters useful for joininng. Again these should map to the
options in the official UCP documetation.

```puppet
class { 'docker_ucp':
  ucp_url                   => 'https://ucp-controller.example.com',
  fingerprint               => 'the-ucp-fingerprint-for-your-install',
  username                  => 'admin',
  password                  => 'orca',
  host_address              => ::ipaddress_eth1,
  subject_alternative_names => ::ipaddress_eth1,
  replica                   => true,
  version                   => '0.8.0',
  usage                     => false,
  tracking                  => false,
}
```

#### Version 2 and newer

In UCP version 2 Docker has changed the underlying cluster scheduler from Swarm legacy to
Swarm mode, because of that change the join flags have also changed.

To join to a v2 manager (formally a controller in v1) please use the following:

```puppet
class { 'docker_ucp':
  version           => '2.1.0',
  token             => 'Your join token here',
  listen_address    => '192.168.1.2',
  advertise_address => '192.168.1.2',
  ucp_manager       => '192.168.1.1',
}
```

### Installing a Docker Trusted Registry

To install a [Docker trusted registry](https://docs.docker.com/datacenter/dtr/2.2/guides/)
(DTR) on to your UCP cluster, please see the following example.

```puppet
docker_ucp::dtr { 'Dtr install':
  install          => true,
  dtr_version      => 'latest',
  dtr_external_url => 'https://172.17.10.104',
  ucp_node         => 'ucp-04',
  ucp_username     => 'admin',
  ucp_password     => 'orca4307',
  ucp_insecure_tls => true,
  dtr_ucp_url      => 'https://172.17.10.101',
  require          => [ Class['docker_ucp']
}
```

In this example we are setting the `install => true` this tells Puppet we want to
configure a new registry. We set the `dtr_version`, this can be any version of the
registry that is compatible with your UCP cluster. The `dtr_external_url` is the URL you
will use to hit the registry, `ucp_node` is the node in the cluster that the registry will
run on, user name and password are self explanatory. `ucp_insecure_tls => true` allows the
use of self signed SSL certs, this should be set to false in a production environment.
`dtr_ucp_url` is the URL that the registry will use to contact the UCP cluster.

#### Joining a replica to a Docker Trusted Registry cluster

To join a replica to your DTR cluster please see the following example.

```puppet
docker_ucp::dtr { 'Dtr install':
  join             => true,
  dtr_version      => 'latest',
  ucp_node         => 'ucp-03',
  ucp_username     => 'admin',
  ucp_password     => 'orca4307',
  ucp_insecure_tls => true,
  dtr_ucp_url      => 'https://172.17.10.101',
  require          => [ Class['docker_ucp']
}
```

In this example we set mostly the same flags as installing the initial install. The main
difference is that we have used the `join` flag not the `install` flag. Please note you
cannot use `install` and `join` in the same block of Puppet code.

#### Removing a Docker Trusted Registry

To remove the DTR from your UCP cluster you need to pass some flags, the flags are the
same as the install flags, except we are setting `ensure => 'absent'`.

```puppet
docker_ucp::dtr { 'Dtr install':
  ensure           => 'absent',
  dtr_version      => 'latest',
  dtr_external_url => 'https://172.17.10.104',
  ucp_node         => 'ucp-04',
  ucp_username     => 'admin',
  ucp_password     => 'orca4307',
  ucp_insecure_tls => true,
  dtr_ucp_url      => 'https://172.17.10.101',
}
```

## Limitations

The docker_ucp module supports the same operating systems as UCP. As of Docker UCP 0.8,
this is limited to:

-   Red Hat Enterprise Linux 7.0, 7.1, and 7.2
-   Ubuntu 14.04 and 16.04
-   CentOS 7.1

## Development

Puppet modules on the Puppet Forge are open projects, and community contributions are
essential for keeping them great. Please follow our guidelines when contributing changes.

To see who's already involved, see the
[list of contributors](https://github.com/puppetlabs/puppetlabs-docker_platform/graphs/contributors).

For more information, see our
[module contribution guide](https://docs.puppet.com/forge/contributing.html).

### Maintainers

This module is maintained by:

-   Gareth Rushgrove <gareth@puppet.com>
-   Scott Coulton <scott.coulton@puppet.com>