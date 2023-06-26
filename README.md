# udpbroadcastrelay Docker Container

This is a docker container "wrapper" for [udpbroadcastrelay](https://github.com/marjohn56/udpbroadcastrelay).

## Overview

The udpbroadcastrelay tool is a simple service that can listen on two separate Networks\VLAN's and
will assist in relaying UDP broadcast messages between the networks. This is useful if you have
created a "protected" VLAN but still want to expose some services to an "unprotected" VLAN.

For instance, in my personal network I have a "protected" VLAN with my internal machines and trusted
devices connected (including a Plex\Jellyfin server). I created a second, untrusted VLAN, for
IoT devices such as TVs, lamps and light bulbs, Amazon Alexa (aka Echo) devices, Google
Chromecasts, etc. I did NOT want those IoT devices to have free access to my network and by
extension to my other machines. The idea of those devices poking around and having an attack vector
on my machines was unnerving. Despite that network division, I do want to relay mDNS and DLNA
traffic between the two networks. All other traffic is still denied. So, the firewall rules on my
router allow mDNS and DLNA traffic and block all else while this relay tool and container handle
the broadcast message relaying.

## Configuration

The host machine that is running the docker container must have network connections to all the
networks you want to listen to, either physical or virtual. The method to tell the container
what ports to listen on and what settings to use for each is by passing in a YAML file with those
listeners configured. The file must be named `udpbroadcastrelay.yml` and at the root of the volume
you mount to the `/data` directory in the docker container.

An example configuration file might look like the following:

```yml
---
Listeners:
  # Syncthing
  - Flags: --id 1 --port 21027 --dev br0 --dev br42
  # Youtube Application on Smart TV support with DLNA streaming support
  - Flags: >-
      --id 2 --port 1900 --dev br0 --dev br42 --multicast 239.255.255.250
      -s 1.1.1.2 --msearch proxy,urn:schemas-upnp-org:device:MediaServer:1
      --msearch dial
  # Minecraft Discovery
  - Flags: --id 3 --port 19132 -dev br0 --dev br42
  # mDNS
  - Flags: --id 4 --port 5353 --dev br0 --dev br42 --multicast 224.0.0.251 -s 1.1.1.1
```

In the example above `br0` and `br42` are playing the role of the network devices to be used for
listening. Again, they can be any network device type such as bridged networks ("br0", "br26")
or raw interfaces ("eno1", "enp4s0", "eth0"). Depending on the complexity of your network it's
entirely possible to have separate listeners using different network interfaces. You should be
able to use one running docker container instance to support **A LOT** of listeners should you
require.

Each listener should have a unique `--id` value. All the other values provided are the command-line
flags and options that are supported by the `udpbroadcastrelay` utility. For more details and some
advanced scenarios, please see that projects
[README](https://github.com/marjohn56/udpbroadcastrelay).

**NOTE:** Do NOT pass in the -f (fork) option to any of the listeners as the script in the container
manages that automatically.

## Setup

1. Ensure that the machine you are running this container on DOES NOT have any Avahi services
   running or listening. They will interfere with TCP port 5353 which this container will need to
   listen on for everything to work (mDNS).
2. Prepare your configuration file (see [Configuration](#configuration) above) and place it
   somewhere you will mount into the docker container.
3. Run this container with either docker, podman, or docker-compose as follows:
   `docker run -d --network=host --restart=unless-stopped --volume /paht/to/config/file:/data --name
udpbroadcastrelay brennanfee/docker-udpbroadcastrelay:latest`

## License

[MIT](license.md) © 2023 [Brennan Fee](https://github.com/brennanfee)
