# Summary
This web application is the core website for SharpeTronics.com. It is a live JAMstack (Jekyll, API's, Markup) example of the power of static websites with micro services that includes all the bells and whistles for comments, newsletter subscriptions, content management systems (CMS), site generators, blog posts, continuous delivery (CD), version management, ecommerce shopping, progressive web applications (PWA), and many more.

Javascript frameworks create more complexity than needed, this example displays minimal need for Javascript; therefore increasing security, reducing file size and complex work environments, increasing load times and reducing the learning curve for web developers, while keeping all the fun and speedy reactivity of the modern web architecture. We enable more focus on design and content; while enabling increased portability, automated testing, speed and security.

No proprietary operating system dependencies required, only Docker Engine super machines and some tender love and care. The base stack is Docker Engine + SCSS ready!

# Architecture Features
* JAMstack (Jekyll, API's, Markup)
* Lightweight, Responsive & Static!
* SCSS ready!
* Developer Friendly
* Docker super machines!
* Distributed CDN with automatic HTTPS
* Blog ready with collections and pagination
* Clean minimal design
* GitHub Pages ready (Free hosting)
* GitHub Actions for expanding Jekyll usability
* < Multi-language content management (*Pending*)
* < InterPlanetary File System (IPFS) with Fleek (*Pending*)
* < Content management system ready with user roles (*Pending*)
* < Comments with administration (*Pending*)
* < Ecommerce shopping (*Pending*)
* < Newsletter subscriptions (*Pending*)
* < Search functionality (*Pending*)
* < Web workers for caching data for speedy progressive web application (PWA) (*Pending*)

# Jekyll Plugins
* Menus
* Tagging
* Feed
* Archives
* Picture Tagging
* Pagination v2
* Language Plugin

*All Ruby dependencies are created and stored in the Docker container. Simple, smooth and sweet :)*

# API's
* Strapi CMS, Jekyll-Admin CMS
* ISSO (Comments)
* Snipcart with Stripe
* Mailjet Newsletters
* Algolia Search
* IPFS Open Web with Fleek

# System Requirements
* Install & Setup Docker Engine (Community)
* Install & Setup Docker-Compose
* Install & Setup Git
* Optional: If using Jekyll picture-tagging plugin, you will need to login to docker container and install the image-magick dependency; see docker-compose.yml file.

*Currently, the integration is maintained with Ubuntu 20.10 Linux operating system, although, it is possible to use with Macintosh or Windows specific OS. The setup with docker and docker-compose will be similar to the Linux workflow; please see **Further Reading** for more details.*

## Clone, Build & Launch
1. In local directory for development, ```git clone https://github.com/SharpeTronics/sharpetronics.github.io```
2. ```cd sharpetronics.github.io```
3. ```docker-compose up```

*Happy Hacking!!! :)*

## Further Reading
* Docker Engine https://docs.docker.com/install/
* Docker Compose https://docs.docker.com/compose/install/
* Jekyll https://jekyllrb.com/
* Git https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
