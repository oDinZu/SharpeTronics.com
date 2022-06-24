---
layout: journal_single

author: Charles #case sensitive, please use capitalization for names.

title: How to Setup a Docker Drone CI with HTTPS
sub_heading: Obiwon Can Oh Be! A digital C3-PO working beside you!

banner_image: "/uploads/2022/r2d2-skywalker.webp" #Size of banner_image 840x473
banner_image_alt: "Skywalker with R2D2"

category: Tutorials
tag: Linux, Drone, CI, How-to
---

> R2D2, you know better than to trust a strange computer! [beeps]

In general, this Drone server enables continuous integration (CI) and is a stepping stone for continuous delivery (CD), including gh-pages and gh-actions like functionality.

For this to function correctly, you will need to have a working instance of Gitea running on your own system.

This tutorial doesn't guide you on how-to create your own HTTPS server using Let's Encrypt and Certbot. I have added the certbot resource below [Setting Up HTTPS Certs] I will document this in more detail in the near future. However, this article is similar to how to get https on your server setup.
[How-to get HTTPS on your server](https://sharpetronics.com/blog/tutorials/2021/12/27/setup-nginx-https-web-server-with-lets-encrypt-plus-strapi-4.0-headless-cms/)

As a stack developer and business owner, I am working on so many things! It is difficult to remember everything, so documentation is critical for me to remember.

**Note 1:** If you see a [name-goes-here], I am linking to the references shared at the end of the article.
**Note 2:** Be sure your firewall `sudo ufw status` allows port 80 and 443. `sudo ufw allow http` && `sudo ufw allow https`.
**Note 3:** If you want to use Docker Engine without sudo, follow this url: [Linux Docker Post-Install](https://docs.docker.com/engine/install/linux-postinstall/)

### Requirements
- Basic Linux CLI knowledge
- A hardened remote SSH server [see Linux VPS hardening](https://sharpetronics.com/blog/tutorials/2021/07/26/linux-vps-hardening-init/)
- A running Gitea server: Git with a cup of tea
- [Docker Engine](https://docs.docker.com/engine/install/)
- a basic understanding of how to use Docker Engine
- basic Nginx, Gitea and Certbot/Let's Encrypt experience
- openssl

### Let's Begin!

#### Preparing the Environment

##### Creating our super-duper-shared secret
```
openssl rand -hex 16
bea26a2221fd8090ea38720fc445eca6
```

##### Creating an OAuth application on Gitea
1. Goto your git.example.com and login
2. Navigate to your profile settings (not the administrator settings, but personal profile)
3. At the top below the main navigation bar, click on **Applications**
4. Scroll down to the bottom of the page and create a new App name and Redirect URI
```
Applications Name: drone
Redirect URI: https://drone.example.com/login
```
5. Click **Create Application**
6. Copy and save your **Client Secret**; you will only be able to see this secret one time.
7. In the next section, we will use these credentials to authenticate with Gitea and launch the Drone server.

#### Create & configure the Docker Container

##### Download docker drone image from Dockerhub
`docker pull drone/drone:2`
`docker image`

##### Begin configuring and starting drone

*The below command creates a container and starts the Docker runner. Remember to replace the environment variables below with your Drone server details.*
```
docker run \
  --volume=/var/lib/drone:/data \
  --env=DRONE_TLS_AUTOCERT=true \
  --env=DRONE_HTTP_SSL_REDIRECT=true \
  --env=DRONE_HTTP_SSL_TEMPORARY_REDIRECT=true \
  --env=DRONE_HTTP_SSL_HOST=drone.example.com \
  --env=DRONE_HTTP_STS_SECONDS=315360000 \
  --env=DRONE_SERVER_CERT=/etc/letsencrypt/live/drone.example.com/fullchain.pem \
  --env=DRONE_SERVER_KEY=/etc/letsencrypt/live/drone.example.com/privkey.pem \
  --env=DRONE_GITEA_SERVER=https://git.example.com \
  --env=DRONE_GITEA_CLIENT_ID=e69c443c-6bc2-4a35-000b-a2f36a885400 \
  --env=DRONE_GITEA_CLIENT_SECRET=3aY2000000c2Np7zX4e1Z9nlYhelENfX7nmWyxsgVixRg \
  --env=DRONE_RPC_SECRET=bea26a2221fd80900000038720fc445eca6 \
  --env=DRONE_SERVER_HOST=drone.example.com \
  --env=DRONE_SERVER_PROTO=https \
  --env=DRONE_USER_FILTER=gitea-user-account \
  --publish=80:80 \
  --publish=443:443 \
  --restart=always \
  --detach=true \
  --name=st-drone-ssl \
  drone/drone:2
 ```

###### Going the extra yards
After you create the docker container, it will automatically restart to remember your configuration, but if you create a shell script, you are able to `./shell-script.sh` and run the Docker image.

```
vi shell-script.sh
copy/paste docker config via CTRL+SHIFT+V
double check for typos
hit ESC
press SHIFT+Z,Z (saves and quits)
chmod +x shell-script.sh (makes script executable)
then, run the script with: ./shell-script.sh
```

#### Verify
```
docker logs st-drone-ssl

INFO[0000] starting the server
INFO[0000] successfully pinged the remote server
```

#### Stop & Start Container
```
sudo docker container stop st-drone-ssl
sudo docker container start st-drone-ssl
```

### Part II - Configure a Drone Runner Pipeline with Docker Engine

This article will be shared at a later date.

### References

- [Setting up HTTPS certs](https://certbot.eff.org/instructions)
- [Drone Configuration Options](https://docs.drone.io/server/reference/)
- [Drone Gitea Setup](https://docs.drone.io/server/provider/gitea/)
- [Drone Server Docker Installation](https://docs.drone.io/server/provider/gitea/)
- [What is CI/CD](https://www.infoworld.com/article/3271126/what-is-cicd-continuous-integration-and-continuous-delivery-explained.html)
- [Unsplash - Studbee](https://unsplash.com/@studbee)

### Support

If you have any questions, concerns, want to say hi, please join the following channel: [SharpeTronics Discord Support Channel]({{ site.data.social.discord_invite }}) Eventually, I plan on having a commenting system on here..

### Donations
Recently, I have had many folk as about **how to send me a donation**. If you want to give back andor support my efforts, I have shared various ways to donate. Thank You!

- [Cash App]({{ site.data.payment.cashapp_acct }})
- [Venmo]({{ site.data.payment.venmo_acct }})
- [Open Collective]({{ site.data.payment.open_collective }})
- **Bitcoin Address:** {{ site.data.payment.bitcoin_addr }}
- **Hush Address:** {{ site.data.payment.hush_addr }}
- **Stellar Address:** {{ site.data.payment.stellar_addr }}
