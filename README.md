# udpbroadcastrelay Docker Container

This is a docker container "wrapper" for [udpbroadcastrelay](https://github.com/marjohn56/udpbroadcastrelay).

## Overview

The udpbroadcastrelay tool is a simple service that can listen on two separate VLAN's and will
assist in relaying some UDP broadcast messages between the networks. This is useful if you have
created a "protected" VLAN but still want to expose some services to an "unprotected" VLAN.

For instance, in my personal network I have a "protected" VLAN with my internal machines and trusted
devices connected (including a Plex\Jellyfin server). I created a second, untrusted VLAN, for
IoT devices such as TVs, lamps and light bulbs, Amazon Alexa (aka Echo) devices, Google
Chromecasts, etc. I did NOT want those IoT devices to have free access to my other machines and
network. Despite that network division, I do want to relay mDNS and DLNA traffic between the two
networks. All other traffic is still denied. So, the firewall rules on my router allow mDNS and
DLNA traffic and block all else while this relay tool and container handle the broadcast relays.

## Setup

1. Ensure that the machine you are running this container on DOES NOT have any Avahi services
   running or listening. They will interfere with TCP port 5353 which this container will need to
   listen on for everything to work (mDNS).
2. Find interfaces on your machine that connect to the two networks\VLAN's that you want to
   broadcast between. Sometimes these might be bridged ("br0", "br26") and other times they might
   be a raw interfaces ("eno1", "enp4s0").
3. Run this container with either docker, podman, or docker-compose as follows:
   `docker run -d --network=host --restart=always -e VLAN1="br0" -e VLAN2="br42" --name
udpbroadcastreleay brennanfee/docker-udpbroadcastrelay`

## License

[MIT](license.md) © 2023 [Brennan Fee](https://github.com/brennanfee)
