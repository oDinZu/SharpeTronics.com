---
layout: post
date: 2022-06-23
author: Charles
banner_image: /uploads/c3po_a_friend_in_need_74a237a413.webp
banner_image_alt: Black and white still image of C3PO
title: How to Setup a Secure Docker Drone Runner with Drone CI
sub_heading: BeeYoop BeeDeepBoom Weeop DEEpaEEya
tags: Linux, Drone CI, Docker, 
category: How-to
---
> BeeYoop BeeDeepBoom Weeop DEEpaEEya

In general, this article describes how to setup SSL with a Drone Runner. This is part II of a part I series. If you would like to learn how-to setup the Drone Server, please visit: [Setup Drone CI Server](https://www.sharpetronics.com/blog/tutorials/2022/06/23/how-to-setup-a-docker-drone-ci-with-https/).

This part II creates a pipeline runner with a Docker machine; what that means is, like GitHub Actions, but with Drone super powers. The configuration file is stored as `.drone.yml` in the root of your site directory and drone server uses that application yml file to do a series of commands or actions within the virtual docker machine.

This is empowering because you can automate a fresh build every time. Also, you create a **drone trigger** for when you push to a branch master as an example. Here is the configuration of all the possible things you can do. [Docker Pipelines Overview](https://docs.drone.io/pipeline/docker/overview/)

**Note 1:** If you see a [name-goes-here], I am linking to the references I shared below.
**Note 2:** If you want to use Docker Engine without sudo, follow this url: [Linux Docker Post-Install](https://docs.docker.com/engine/install/linux-postinstall/)

### Requirements
- Basic Linux CLI knowledge
- A hardened remote SSH server [see Linux VPS hardening](https://sharpetronics.com/blog/tutorials/2021/07/26/linux-vps-hardening-init/)
- A running Gitea server: Git with a cup of tea
- [Docker Engine](https://docs.docker.com/engine/install/)
- a basic understanding of how to use Docker Engine
- basic Nginx, Gitea and Certbot/Let's Encrypt experience
- openssl
- a running drone ci server [see part I](https://www.sharpetronics.com/blog/tutorials/2022/06/23/how-to-setup-a-docker-drone-ci-with-https/)

### Let's Begin!

#### Pull docker image from dockerhub
`docker pull drone/drone-runner-docker:1`

#### Make public access to repo in drone GUI
For testing, I made sure the repo was publicly available.

![Screenshot Drone UI](/uploads/2022/screenshot-drone-gui.webp)

### Launch a Secure Docker Drone Runner

For the **DRONE_RPC_SECRET** use the same ssl secret we created in Part I. See [Configuration](https://docs.drone.io/runner/docker/configuration/reference/) for a complete list of configuration options.

Please see the reference to understand what this docker config is doing. That is important for you to do yourself.

```
docker run --detach \
  --volume=/var/run/docker.sock:/var/run/docker.sock \
  --env=DRONE_RPC_PROTO=https \
  --env=DRONE_RPC_HOST=drone.example.com \
  --env=DRONE_RPC_SECRET=bea26a2221fd8090ea38720fc445eca6 \
  --env=DRONE_RUNNER_CAPACITY=2 \
  --env=DRONE_RUNNER_NAME=st-runner \
  --env=DRONE_UI_USERNAME=youruserhere \
  --env=DRONE_UI_PASSWORD=yourpasshere \
  --env=DRONE_DEBUG=true \
  --env=DRONE_TRACE=true \
  --publish=3000:3000 \
  --restart=always \
  --name=st-drone-runner \
  drone/drone-runner-docker:1
```

#### A Pipeline Config Example

An example of a custom pipeline I have created. I ain't going to explain this to you in detail; I expect you to determine your own pipeline and this is only for a reference point. Essentially, what you will be doing is launching your own virtual machine for your specific use case scenario.

In this example, on drone.example.com, I have created a secret pass that needs to be passed to the virtual machine so I can package the build aka **_site** only, then auto push to www_data branch on my git server. Furthermore, I **rsync** this data through an ssh tunnel to a **Gitea Pages** server that serves the **WWW or edge** data.

**Note: 3:** The example configuration is a **.drone.yml** file stored in the root of your site project.

```
---
kind: pipeline
type: docker
name: build

workspace:
  path: /drone/src

platform:
  os: linux
  arch: amd64

trigger:
  branch:
  - master

steps:
- name: build-website
  image: ruby:latest
  environment:
    SSH_USER:
      from_secret: ssh_user
    SSH_HOST:
      from_secret: ssh_host
    NO_HOSTKEY:
      from_secret: no_hostkey
  privileged: false
  volumes:
    - name: jekyll
      path: /srv/jekyll

  commands:
    # general vm information for debugging
    - whoami
    - pwd
    - gem environment
```

#### Verify
```
docker logs st-drone-runner

INFO[0000] starting the server
INFO[0000] successfully pinged the remote server
```
#### Stop & Start Container
```
sudo docker container stop st-drone-ssl
sudo docker container start st-drone-ssl
```
### References
- [Drone Runner Configuration](https://docs.drone.io/runner/docker/configuration/reference/)
- [Drone Runner Docker Installation](https://docs.drone.io/runner/docker/installation/linux/)
- [Docker Pipelines Overview](https://docs.drone.io/pipeline/docker/overview/)
- [Unsplash - Nice M Nshuti](https://unsplash.com/@nietzsche99)

### Support

If you have any questions, concerns, want to say hi, please join the following channel: [SharpeTronics Discord Support Channel]({{ site.data.social.discord_invite }}) Eventually, I plan on having a commenting system on here..

### Want to buy me a coffee?
Recently, I have had many folk as about **how to send me a donation**. If you want to give back andor support my efforts, I have shared various ways to donate. Thank You!

- [Cash App]({{ site.data.payment.cashapp_acct }})
- [Venmo]({{ site.data.payment.venmo_acct }})
- [Open Collective]({{ site.data.payment.open_collective }})
