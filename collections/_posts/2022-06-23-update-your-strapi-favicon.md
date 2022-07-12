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
In this article, we will be replacing the Strapi favicon with your own favicon. Furthermore, this same process is similar to how we replace the login logo `AuthLogo` and menu logo with `MenuLogo'. For more details, please visit Strapi documentations example configuration. [Strapi Documents] 

#### Create an extensions folder in: `src/admin/extensions/`

#### Upload your favicon into: `src/admin/extensions/`

#### Replace the **favicon.ico** at `Strapi app root` with your favicon.ico

#### Update your `src/admin/app.js` with the following:
```
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
#### Rebuild, run & revisit your Strapi app `yarn build && yarn develop`
Your Strapi app should now have your updated favicon.

*Note: Be certain the *cached favicon* is **cleared**. It can be cached in your web browser and also with your domain management tool like Cloudflare's CDN*

#### References
[Strapi Documents](https://docs.strapi.io/developer-docs/latest/development/admin-customization.html#configuration-options)

#### Support

If you have any questions, concerns, want to say hi, please join the following channel: [SharpeTronics Discord Support Channel]({{ site.data.social.discord_invite }}) Eventually, I plan on having a commenting system on here..

#### Buy me a coffee?
Recently, I have had many folk as about **how to send me a donation**. If you want to give back andor support my efforts, I have shared various ways to donate. Thank You!

- [Cash App]({{ site.data.payment.cashapp_acct }})
- [Venmo]({{ site.data.payment.venmo_acct }})
- [Open Collective]({{ site.data.payment.open_collective }})