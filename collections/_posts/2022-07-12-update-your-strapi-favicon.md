---
layout: journal_single

author: Charles #case sensitive, please use capitalization for names.

title: Update your Strapi CMS with your own Favicon
sub_heading: How-to replace the favicon

banner_image: "/uploads/2022/code.webp" #Size of banner_image 840x341
banner_image_alt: "Macguyvering Strapi"

category: Tutorials
tag: How-to, Strapi, Configuration
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

#### Support

If you have any questions, concerns, want to say hi, please join the following channel: [SharpeTronics Discord Support Channel]({{ site.data.social.discord_invite }})