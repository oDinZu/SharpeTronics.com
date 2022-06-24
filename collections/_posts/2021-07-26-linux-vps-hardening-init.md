---
layout: journal_single

author: Charles #case sensitive, please use capitalization for names.

title: Linux VPS Hardening
sub_heading: Initializing a secure environment

banner_image: "/uploads/2021/linux-admin.webp" #Size of banner_image 840x473
banner_image_alt: "Decentralized Internet Dfinity"

category: Tutorials
tag: Linux, VPS, Administration
---
### Planting Seeds

Administration of a virtual private Linux server (VPS) without a GUI cpanel is the only way to go. Going through any graphical user interface (GUI) to run critical services for your company is like playing the telephone game. Securing our environment begins at the terminal & from terminal experience we create a deeper learning experience for ourselves and build confidence along the way.

This article will extrapolate on initializing a Ubuntu Linux VPS for the first time and how we secure our environment through the terminal. No Windows or MacOS pancakes here; only Linux.

When beginning a new server or garden, the soil is most important; we create an environment to protect and maximize growth potential. The VPS provider may give you an OS they installed, but I always create a fresh install myself.

### Logging in via SSH

##### Creating RSA Public Key
Before you are able to login with SSH, you will most likely have to generate and add a RSA public key.

`ssh-keygen -t rsa -b 4096`

##### Copy / Paste Public Key
After key is generated, we display the public key and add it to VPS account. *Optionally, you may have to add the key with ssh-copy-id user@ip_address.*

`cat ~/.ssh/id_rsa.pub`

```
ssh-rsa AAAEXAMPLECAQDBn0Z88lqrtya0Nd7yYtP/1o90vwVxjvCm/txb+SW85JRRnrI616d2iWwtVCSiUX0s59FfIPxUJl6vPqmxY40DIrX9KZijVpaq/TzWXh2ktCTjT6uBNMBRz/2lxP3w2AZov65dygjW5eQT9K9YB13dr1B4RkQMmUW5xiFbdHM0WzBYM2CMtE+lnmebn7m+B3DcvNkuGdT9Qw1/J24dTuNJSzJXVxzTOTlnVKOVSp1NWzu0USFI6dkrz8YImSgP9hQX970zTnzQ1Ctei4xlR/IiCpVGG6zWeV4oT3sLf4E9mk9eYF/wU0AdA3mQ68yZvv+Bhlc75e9kmUFe+JbctKR4YaKGY6K6K/F1tHrKYkASEkfQQ0KJU/ez/wtSf21A6Z2bM/Gg28f/6owfIMPWnYuB9VOLqkdIHFUot40uMi9CBvkdwH69zAQfz4jFvmu588klE0usBclGAFs78KM6YWaXHYjHdWVRIUrAqdZw1IP0uYS3uSBUPsbBG/Aq0V+22dg8U5DSu5XmwLB5jT+3c4ScqH3kY5tomRLe+2Dx4K+mAHpgtf10xL6Ayx2y0GFZCf+LB1Va3Trk3ChcaKRF5KvyayFQNSY4AfA47B90asdv== user@hostname
```

##### SSH into VPS
Next, we login to our VPS and specify -i what key to use. The -i is only needed if you have more than one key. The -v displays verbose or details of what the command is doing in the terminal.

`ssh -i ~/.ssh/id_rsa root@123.123.123.123`

Success! Now, we are able to update and upgrade our packages.

### Prepping Linux Environment

##### Update Sources & Packages
`apt-get update && apt-get upgrade`

##### Disable Ubuntu Sudo Timeout
In Ubuntu, sudo has a timeout built in for ease of use. I personally remove this timeout; without knowing you are using sudo will create all kinds of headaches in the future. When you make use of root privileges, we must explicitly type sudo each command.

`sudo visudo`

add `Defaults        env_reset, timestamp_timeout=00`

### Setting Up The Firewall
After we have logged in via SSH for root user account. I recommend installing a powerful firewall called: **ufw**

`apt-get install ufw`

`ufw status`

`ufw allow ssh`

Display the status of the firewall and determine if ssh has been allowed. If nomenclature *ssh* doesn't add the ports, we do this manually with ufw allow 22/udp & ufw all 22/tcp. Port 22 is the common port SSH server makes use of; we are able to change this port for extra hardening, but for the sake of this tutorial, we will use port 22.
`ufw status`

```
To                         Action      From
--                         ------      ----
22/tcp                     ALLOW        Anywhere                  
22/udp                     ALLOW        Anywhere
```

Now, we enable the firewall **after** we allow port 22. The SSH connection should remain open. If it closes, SSH back into your VPS.
`ufw enable`

##### Check If Port Is Open
Once telnet is ran, ssh information should populate
`telnet 123.123.123.123 22`

```
Trying 123.123.123.123...
Connected to 123.123.123.123.
Escape character is '^]'.
SSH-X.0-OpenSSH_X.2p1 Ubuntu-Xubuntu0.2

Invalid SSH identification string.
Connection closed by foreign host.
```

### Creating New Users & Permissions

To further expand on the garden, we must define a secure space for each plant or service we are running. To manage each service, like dns, mail, gitea, etc... we create a new user for each of these environments. This separation is important for operational security (OPSEC).

`adduser username` *Note: If we want to use Dockerfile or auto script without prompts, we make use of the **useradd** command.*

```
Adding user `username' ...
Adding new group `username' (1003) ...
Adding new user `username' (1002) with group `username' ...
Creating home directory `/home/username' ...
Copying files from `/etc/skel' ...
New password:
```

Next, if the user should have sudo permission, we do the following.

`usermod -a -G sudo username`

##### Prove User was Created

`cat /etc/passwd`

```
...
username:x:1001:1002:User Name,,,:/home/username:/bin/bash
...
```

##### Logging In with New Username

`su username`

##### Update SSH Config
`sudo nano /etc/ssh/sshd_config`

Add sudo to the **AllowGroups** like so:

`AllowGroups wheel root sudo`

Next, we disable root login since we will only have root privileges when using sudo.

`PermitRootLogin no`

##### SSH Directory Creation For New Username
Creating new user access to SSH login.
When you connect to new username@ip, the vps user needs the public key for verification of authorized user. Authorized users with correct **private key** will be able to login to vps via ssh protocol.

`mkdir ~/.ssh`

`nano ~/.ssh/authorized_keys`

Paste your public key we created earlier into the authorized_keys file.

##### Update file & folder permissions

`chmod 700 ~/.ssh`

`chmod 600 ~/.ssh/authorized_keys`

##### Restart SSH service

`sudo service ssh restart`

`exit`

In conclusion, we are now able to login via SSH with new user and have also disabled root user logins.
This process will have to be done for each user that is created.

### Backups with Rsync Superpowers!

After all our hard work and focus, we should backup our VPS and create scheduled routines. Depending on your use case, I would recommend at least weekly backups.

The following command is quite complex, but, essentially we are discarding folders we don't need, backing up the entire VPS to our local machine and preserving all permissions and file integrity from the VPS.

- rsync - A fast, versatile, local and remote file-copying utility
- -aAXv - The files are transferred in "archive" mode, which ensures that symbolic links, devices, permissions, ownerships, modification times, ACLs, and extended attributes are preserved.
- / - Source directory
- --exclude - Excludes the given directories from backup.

```
sudo rsync -aAXv --rsh="ssh -i /home/user/.ssh/id_rsa" --recursive --progress --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/backups/*"} user@123.123.123.123:/ /home/user/VPS/Backups/
```

#### Sources:
* Full System Backup Using Rsync - <https://wiki.archlinux.org/title/Rsync#Full_system_backup>

### Support

If you have any questions, concerns, want to say hi, please join the following channel: [SharpeTronics Discord Support Channel](https://discord.gg/HQcvr2JBQv) Eventually, I plan on having a commenting system on here..

### Donations
Recently, I have had many folk as about **how to send me a donation**. If you want to give back andor support my efforts, I have shared various ways to donate. Thank You!

- [Cash App](https://cash.app/$sharpeee)
- [Venmo](https://account.venmo.com/u/seabeeess)
- [Open Collective](https://opencollective.com/sharpetronics)
- **Bitcoin Address:** 1BszkJe66oYps5PNwivFBBNTo1PAFYTMwF
- **Hush Address:** zs1qx8dutj96kdcx29a4070pumzdqsk7vnayk4pf8tf6duj304y4akey9ze39upzz9qtchculp8mdw
- **Stellar Address:** GARFNIQZPE5SHGJSR25AIFWWGUB7GJIW4TVZ5ZUSEP5VMJIVIUONANK4
