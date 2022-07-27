---
layout: post
date: 2022-06-21
author: Charles
banner_image: /uploads/ejabberd_in_the_jungle_8a9f00e089.webp
banner_image_alt: Compiling Fresh XMPP Ejabberd Server Binaries 22.05 on Ubuntu 20.04 with Erlang OTP 24
title: Compiling Fresh XMPP Ejabberd Server Binaries 22.05 on Ubuntu 20.04 with Erlang OTP 24
sub_heading: Creating and host your own end-to-end encryption Instant Messenger app
tags: Linux, XMPP, Ejabberd, 
category: Devops
---
# Compiling ejabberd v22.05
### A XMPP server based on Erlang/OTP 24

**Note 1:** I personally took it upon myself to use the following format [Example-Reference] to *tag* references.

In this article, I will be sharing a *HOWTO* create your own end-to-end encrypted instant messenger(IM) XMPP service for your Company, family xor community. Having ownership of your data requires **work** and this setup allows any Human in the world to protect their digital data from those who sell it for profit.

> "Ejabberd is a complete open-source XMPP-based messaging solution that is for all human beings, but ideal for governments, police, military, banks, insurance, finance, and healthcare companies that value privacy and security."

The minimal cost is less than $100 per year and is portable with the *nifty* config option -with-rebar; this option packages the whole app for transport.

### Configure & compile Ejabberd

Please see [Ejabberd Configure] for setting up your Linux environment.

#### Requirements
- A remove server that has been hardened [Linux VPS Hardening](https://www.sharpetronics.com/blog/tutorials/2021/07/26/linux-vps-hardening-init/)
- Linux CLI knowledge
- Patience

#### Operating System
- This article is tested with `cat /etc/os-release` VERSION="20.04.4 LTS (Focal Fossa)"

#### Dependencies:
- GNU Make `make -v`
- GCC `sudo apt install build-essential && gcc -v`
- Libexpat 1.95 or higher `sudo apt install -y expat && libexpat-dev`
- Libyaml 0.1.4 or higher `sudo apt install -y libyaml-dev`
- Erlang/OTP 19.3 or higher. We recommend using Erlang OTP 21.2. `sudo apt install -y erlang && erl -v`
- OpenSSL 1.0.0 or higher, for STARTTLS, SASL and SSL encryption. `sudo apt install -y libssl-dev`
- Zlib 1.2.3 or higher. Optional. For Zlib Stream Compression `sudo apt install -y zlib1g && zlib1g-dev`
- ImageMagick’s Convert program and Ghostscript fonts. Optional. For CAPTCHA challenges. `sudo apt install -y imagemagick`

- PAM library. *Optional*. For PAM Authentication
- Elixir 1.10.3 or higher. *Optional*. For Elixir Development

#### Extras Deps I needed
- **PostgreSQL** `sudo apt install -y postgresql postgresql-contrib && sudo systemctl start postgresql.service`
- **Erlang-dev** I had too also install erlang-dev for *erl_nif.h* was missing `sudo apt install -y erlang-dev`
- **eunit_autoexport** was missing at compile `sudo apt-get install -y erlang-eunit`
- **erlang-parsetools** was needed to create and assemble the 22.05.tar.gz. `sudo apt-get install -y erlang-parsetools`

### Clone Ejabberd 22.05
```
git clone https://github.com/processone/ejabberd.git && cd ejabberd
git checkout tags/22.05 -b branch-name-example && git status
```
**Note 2-3:** the latest stable release is 22.05 on June 21, 2022. Verify you are on branch-name-example.

#### We begin compiling and installng **ejabberd** after the environment is ready

Below, I had to create my **configure** file with *autogen*. The **configure** options I have included are: postgresql database (default: mysql), zlib compression algos (optional), extra dev tools (optional) and rebar for packaging everything into one portable app.(optional) To see more options, please visit: [Ejabberd Configure](https://github.com/processone/ejabberd/blob/22.05/COMPILE.md)

```
./autogen.sh
./configure --enable-pgsql --with-rebar=rebar3 --enable-tools --enable-zlib --enable-debug
make rel
```
**Note 4-6:** if you want to clean up the make after errors, use *make distclean* for dev files and clean for binaries. You are also able to see all the options for make via `make help`. Make rel creates a static portable binary release; no need to sudo make install, simply launch the app from the directory.

### Eureka! :party-hat
```
===> Release successfully assembled: _build/prod/rel/ejabberd
===> Building release tarball ejabberd-22.05.tar.gz...
===> Tarball successfully created: _build/prod/rel/ejabberd/ejabberd-22.05.tar.gz
```
### Prepare Ejabberd Binary

After we have successfully compiled ejabberd binaries on our own system, we have a system to create fresh binaries that are portable on the fly! Furthermore, we rename the ejabberd folder to ejabberd_builder and copy the created tar.gz to desired location.

```
cd .. && mv ejabberd ejabberd_builder
cp _build/prod/rel/ejabberd/ejabberd-22.05.tar.gz ~/nodes/

```

### Launch Ejabberd

Next, we untar or extract the data into the appropriate directory.
```
cd ~/nodes/ && mkdir ejabberd-20.05
tar -xvkf ejabberd-20.05.tar.gz -C ./ejabberd-20.05
cd ejabberd-20.05/ && ls bin/
./bin/ejabberdctl start
./bin/ejabberdctl status
```

> NOW, the hard part... configuration of your fresh ejabberd binaries.

As you may have noticed, **ejabberdctl** status failed to start. This is because we now have to configure the server.

##### PART II - TBA

### References:

- [Ejabberd Source](https://github.com/processone/ejabberd/blob/22.05/COMPILE.md)
- [Ejabberd Compile](https://docs.ejabberd.im/admin/installation/#source-code)
- [Ejabberd Features](https://www.ejabberd.im/)
- [Ejabberd Configure](https://www.process-one.net/blog/how-to-configure-ejabberd-to-get-100-in-xmpp-compliance-test/)
- [Linux VPS Hardening](https://www.sharpetronics.com/blog/tutorials/2021/07/26/linux-vps-hardening-init/)
- [OMEMO Extension](https://conversations.im/omemo/)
- [XMPP Servers](https://xmpp.org/software/servers/)

### Support

If you have any questions, concerns, want to say hi, please join the following channel: [SharpeTronics Discord Support Channel]({{ site.data.social.discord_invite }}) Eventually, I plan on having a commenting system on here..

### Want to buy me a coffee?
Recently, I have had many folk as about **how to send me a donation**. If you want to give back andor support my efforts, I have shared various ways to donate. Thank You!

- [Cash App]({{ site.data.payment.cashapp_acct }})
- [Venmo]({{ site.data.payment.venmo_acct }})
- [Open Collective]({{ site.data.payment.open_collective }})
