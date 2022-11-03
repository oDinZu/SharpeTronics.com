---
updatedAt: 2022-10-15T18:40:33.689Z
layout: post
title: Update your Strapi CMS with your own Favicon
subheading: How-to replace the favicon
slug: update-your-strapi-cms-with-your-own-favicon
date: 2022-07-12
author: Charles
author_image: /uploads/c_avatar_30ba895a14.webp
banner_image: /uploads/code_2b5ed5fa9c.webp
banner_image_description: computer code matrix
category: How-to
tags: Jekyll, Strapi, Headless CMS, 
---
&nbsp;&nbsp;&nbsp;&nbsp;In this article, we will be replacing the Strapi favicon with your own favicon. This same process is similar to how we replace the login logo `AuthLogo` and menu logo with `MenuLogo`. For more details, please visit Strapi documentations example configuration. [Strapi Documents] 

> **Tip:** This same process may be used to replace the login logo `AuthLogo` and menu logo with `MenuLogo`. 
> For more details, please visit [Strapi Documents](https://docs.strapi.io/developer-docs/latest/development/admin-customization.html#logos)

1. Create an extensions folder at:
`src/admin/extensions/`

2. Upload your favicon into:
`src/admin/extensions/`

3. Replace the **favicon.ico** at:
`Strapi app root` with custom favicon.ico

4. Update your `src/admin/app.js` with the following:

```
// path: src/admin/app.js

import favicon from './extensions/favicon.png';

export default {
  config: {
         // replace favicon with custom icon
         head: {
                favicon: favicon,
        },
  }
}
```
5. Rebuild, run & revisit your Strapi app
 `yarn build && yarn develop`

> **Note:** 
> Be certain that the cached favicon is cleared. It can be cached in your web browser and also with your domain management
> tool like Cloudflare's CDN

#### References
[Strapi Documents](https://docs.strapi.io/developer-docs/latest/development/admin-customization.html#configuration-options)
