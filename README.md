[![Puppet
Forge](http://img.shields.io/puppetforge/v/puppetlabs/docker_ucp.svg)](https://forge.puppetlabs.com/puppetlabs/docker_ucp)
[![Build
Status](https://travis-ci.org/puppetlabs/puppetlabs-docker_ucp.svg?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-docker_ucp)

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with docker_ucp](#setup)
3. [Usage - Configuration options and additional functionality](#setup)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

The [Docker Universal Control
Plane](https://www.docker.com/products/docker-universal-control-plane) (UCP)
module helps with setting up a UCP controller, and joining nodes to it.

## Module Description

This module provides a single class, `docker_ucp`, which uses the
official `docker/ucp` container to bootstrap a UCP controller, or join
a node to at existing UCP.

## Setup

The module assumes Docker is already
installed on the host. If you would like to do that with Puppet look at
the [Docker module](https://forge.puppetlabs.com/garethr/docker).

You can install the module using the Puppet module tool like so:

```
puppet module install puppetlabs/docker_ucp
```

## Usage

The included class has two modes of operation:

### Installing a Controller

```puppet
class { 'docker_ucp':
  controller => true,
}
```

This will install a UCP controller using Docker, with the default
`admin/orca` username and password. Remember to login and change the
password once UCP is up and running.

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

### Joining a Node to UCP

You can use the same class on another node to join it to an existing
UCP.

```puppet
class { 'docker_ucp':
  ucp_url     => 'https://ucp-controller.example.com',
  fingerprint => 'the-ucp-fingerprint-for-your-install',
}
```

The default username and password are used, so it's likely that you'll
need to provide those in parameters. The class also takes a number of
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

## Limitations

As of Docker UCP 0.8, UCP only supports RHEL 7.0, 7.1, Ubuntu 14.04
and CentOS 7.1, therefore the module only works on those operating
systems too.


## Maintainers

This module is maintained by: Gareth Rushgrove <gareth@puppet.com>
