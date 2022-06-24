---
layout: journal_single

author: Charles #case sensitive, please use capitalization for names.

title: Setup a Secure NGINX HTTPS Web Server with Let's Encrypt + Strapi 4.0 Headless CMS
sub_heading: Static Websites with CMS

banner_image: "/uploads/2021/santa-rudolph-unsplash.webp" #Size of banner_image 840x560
banner_image_alt: "Qt5 Compile"

category: Tutorials
tag: Linux, Strapi, Nginx, JAMstack

updated: December 27, 2021
---

## General
For this tutorial, we will launch a secure SSL NGINX web server for your website domain example.org and enable an API to be consumed from the subdomain i.e. api.example.org with Strapi 4.0.

*Tip:* For each reference, I add the **[reference name]** in brackets at the end of the "transmission." **[AWK example]**

## Requirements:
- a Ubuntu Linux 20.04 VPS with SSH access
- CLI knowledge
- a registered web domain i.e. example.org
- Basic knowledge of DNS and managing a VPS with SSH

## Dependencies & Packages
- NodeJS v12 or v14 (v14 is recommended for Strapi 4.0)
- Npm v6+ & Yarn (Yarn is optional)
- Certbot with Let's Encrypt
- Nano editor

## Prepare Operating System
Let's Begin! We begin by installing nginx, certbot and verifying versions Strapi needs. Keep in mind, if you are reading this from the future, the versions will change.

### Update System

```sudo apt update```

### Install Nginx Certbot Packages

```sudo apt install certbot python3-certbot-nginx```

### Install NGINX & verify version

```sudo apt install nginx```

```node -v && nginx -v```

**Tip:** Strapi recommends nodejs v14, but v12 works.

### Install Yarn (Corepack)
```npm i -g corepack``` **[Install Yarn]**

## Configure NGINX
Next, we will configure your newly installed Nginx server. By default the configurations are located at: /etc/nginx/ & /etc/nginx/sites-available/. To keep things tidy and organized, we create a new api.example.org conf for each domain we are publicly facing to WWW.

### Make Directory & Copy Default HTML page

```sudo mkdir -p /var/www/api.example.org/html/```

```sudo cp -R /var/www/html/index.nginx-debian.html /var/www/api.example.org/html/index.html```

### Duplicate Default Config

```sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/api.example.org```

### Update NGINX api.example.org Config File

The **Proxy Config** is important and allows the Strapi 4.0 server to run with nginx. In general, the rest allows SSL and redirects all HTTP traffic to HTTPS, plus denies automated user-agents like wget.

```
server {
        # Redirect all HTTP requests to HTTPS
        listen 80;
        server_name _;
        return 301 https://$host$request_uri;

        # Deny Automated User-Agents
        if ($http_user_agent ~* (netcrawl|npbot|malicious|LWP::Simple|BBBike|wget)) {
        return 403;
        }
}

server {
    # Listen HTTPS
    listen 443 ssl http2; # managed by Certbot
    listen [::]:443 ssl http2;
    server_name api.example.org www.api.example.org;

    # sites document root
    root /var/www/api.example.org/html;
    index index.html index.htm;

    # SSL Config
    ssl_certificate /etc/letsencrypt/live/api.example.org/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/api.example.org/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    # Proxy Config
    location / {
        proxy_pass http://strapi;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_pass_request_headers on;
    }

}

```
``` CTRL+X, then Y for Yes to save```

### Symbolic Link to sites-enabled
This creates a 'mirror' like reference to the sites-available folder.

```sudo ln -s /etc/nginx/sites-available/api.exampleorg /etc/nginx/sites-enabled/```

#### Verify Symbolic Link
```ls /etc/nginx/sites-enabled/```

## DNS Configuration
We now point our domain to the server we are hosting our Strapi on. i.e. 123.123.1.1

### Update DNS Settings
Depending on your DNS provider or maybe you have your own Domain Name Server, we point our DNS settings for example.org to 123.123.1.1 as type A. I personally recommend Cloudflare.

## Create SSL Certs
We run the automated tool Certbot and create all the needed files and update our *api.example.org* configuration file.

### Run Certbot
```sudo  certbot --nginx```

```Choose api.example.org for the site to create certs. for.```

```Choose option 1 to disable auto redirect HTTP traffic to HTTPS since we already redirected the traffic manually.```

**Note** sudo certbot renew --dry-run will test for automatic renewal for your certs. [Certbot Insturctions]

### Verify api.example.org Updated with Correct Domain

```sudo nano /etc/nginx/sites-enabled/api.example.org```

### Test Config & Restart Nginx

```sudo nginx -t```

```sudo systemctl restart nginx```

## Firewall Configuration
Allow public to connect via HTTPS, we need to open up ports 80 & 443 (HTTP & HTTPS).

### Allow UFW Ports for Public Traffic
```sudo ufw allow HTTPS```

```sudo ufw allow HTTP```

### Verify Status & Reload UFW
```sudo ufw status```

```sudo ufw reload```

**Tip** sudo ufw allow 'Nginx Full' opens both port 80 & 443 (For SSL / TLS encryption).

## Getting Started with Strapi
Now, we must install Strapi 4.0 on the server and launch the Strapi server.

### Strapi Default Installation
Goto desired place to install Strapi project i.e. ~/development/my-strapi-project, then,

```yarn create strapi-app my-project```

**Note:** The default Strapi installation uses SQLite as the database. You are able to use other databases like PostgreSQL. See **[Strapi Installation]** for more details.

### Launch Strapi Development Server

```yarn develop```

### Launch Strapi from Domain URL

```Goto: api.example.com via web browser of your choice.```

```Follow the instructions and continue creating a new Strapi administrator.```

#### References:
[Nginx Strapi Configuration](https://docs.strapi.io/developer-docs/latest/setup-deployment-guides/deployment/optional-software/nginx-proxy.html#nginx-upstream)

[Strapi Installation](https://docs.strapi.io/developer-docs/latest/setup-deployment-guides/installation/cli.html#creating-a-strapi-project)

[Nginx Server Blocks](https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-virtual-hosts-on-ubuntu-16-04)

[Install Yarn](https://yarnpkg.com/getting-started/install)

[Certbot Insturctions](https://certbot.eff.org/instructions?ws=nginx&os=ubuntufocal)

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
