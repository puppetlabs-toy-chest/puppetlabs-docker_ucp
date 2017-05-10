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

# Version =< 1
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
# Version 2 and above
In UCP version 2 Docker has changed the underlying cluster scheduler from Swarm legacy to Swarm mode, because of that change the join flags have also changed.
To join to a v2 manager (formally a controller in v1) please use the following:

```puppet
class { 'docker_ucp':
  version => '2.1.0',
  token => 'Your join token here',
  listen_address => '192.168.1.2',
  advertise_address => '192.168.1.2',
  ucp_manager => '192.168.1.1',
}
```

# Installing a Docker Trusted Registry
To install a [Docker trusted registry](https://docs.docker.com/datacenter/dtr/2.2/guides/) (DTR) on to your UCP cluster, please see the following example.

```puppet 
docker_ucp::dtr {'Dtr install':
  install => true,
  dtr_version => 'latest',
  dtr_external_url => 'https://172.17.10.104',
  ucp_node => 'ucp-04',
  ucp_username => 'admin',
  ucp_password => 'orca4307',
  ucp_insecure_tls => true,
  dtr_ucp_url => 'https://172.17.10.101',
  require => [ Class['docker_ucp'] 
  }
```
In this example we are setting the `install => true` this tells Puppet we want to configure a new registry. We set the `dtr_version`, this can be any version of the registry that is compatible with your UCP cluster. The `dtr_external_url` is the URL you will use to hit the registry, `ucp_node` is the node in the cluster that the registry will run on, user name and password are self explanatory. `ucp_insecure_tls => true` allows the use of self signed SSL certs, this should be set to false in a production environment. `dtr_ucp_url` is the URL that the registry will use to contact the UCP cluster.

## Joining a replica to your Docker Trusted Registry Cluster
To join a replica to your DTR cluster please see the following example.
```puppet
docker_ucp::dtr {'Dtr install':
  join => true,
  dtr_version => 'latest',
  ucp_node => 'ucp-03',
  ucp_username => 'admin',
  ucp_password => 'orca4307',
  ucp_insecure_tls => true,
  dtr_ucp_url => 'https://172.17.10.101',
  require => [ Class['docker_ucp'] 
  }
```

In this example we set mostly the same flags as installing the initial install. The main difference is that we have used the `join` flag not the `install` flag. Please note you can not use `install` and `join` in the same block of Puppet code.

## To remove your Docker Trusted Registry.
To remove the DTR from your UCP cluster you need to pass some flags, the flags are the same as the install flags, except we are setting `ensure => 'absent'` 
```puppet
docker_ucp::dtr {'Dtr install':
    ensure => 'absent',
    dtr_version => 'latest',
    dtr_external_url => 'https://172.17.10.104',
    ucp_node => 'ucp-04',
    ucp_username => 'admin',
    ucp_password => 'orca4307',
    ucp_insecure_tls => true,
    dtr_ucp_url => 'https://172.17.10.101',
    }
```   
  
## Limitations

As of Docker UCP 0.8, UCP only supports RHEL 7.0, 7.1, 7.2, Ubuntu 14.04, 16.04
and CentOS 7.1, therefore the module only works on those operating
systems too.


## Maintainers

This module is maintained by: 

Gareth Rushgrove <gareth@puppet.com>

Scott Coulton <scott.coulton@puppet.com>
