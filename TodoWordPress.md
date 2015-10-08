# 2.8 #
### No Brainers ###
  * Use WordPress Plugins database to make use of WordPress plugin update notifications
### Short Term ###
  * Integrate Mailhide
    * Remove unnecessary options. **Done**
    * Don't describe MailHide; give an example. Link to the [user](http://mailhide.recaptcha.net/) page instead. **Done**
    * Don't show CSS or Regex as options in the admin panel. Show the CSS class for hidden emails on the admin page. **Done**
    * Check for mcrypt PHP module: We can use **extension\_loaded**. Show an alert of this on the admin page. **Done**
```
    if (extension_loaded('mcrypt'))
```
  * Option to turn off reCAPTCHA for admins. **Done**
  * Option to turn off MailHide for admins. **Done**
  * Use a recaptcha.css stylesheet for all recaptcha styling inside and outside of the admin interface. **Done**
  * Drop down list for preset themes. [More Info](http://recaptcha.net/apidocs/captcha/client.html). **Done**
  * Drop down list for languages. **Done**
  * What of <a href='me@haha.com'>Email Me</a>. Will need new regex for searching for links with emails in them or something similar, then make a function similar to recaptcha\_mailhide\_html without the emailparts padded on both sides. This will replace the href part of the link but not touch the link text, therefore preserving the desired and expected effect. **Done**
  * A way to bypass the MailHide filter. Something like `[nohide][/nohide]`. Should be possible with another regular expression. **Done**
    * Took forever but now working. Should we allow users to set the name of the tag themselves? Default nohide though? Probably would just confuse users.
  * XHTML 1.0 Strict compliant [W3 Validator](http://validator.w3.org/). **Done**
    * (_First make sure this is fine, had to edit the actual recaptchalib.php file and remove line 125 the iframe line and then encapsulate the contents of the noscript tags with a div tag. Not sure what the effects of removing the iframe line are but everything seems to be working fine_)
  * Add option to add reCAPTCHA to the registration form. **Done**
  * Fix the Akismet conflicts: WordPress Hook priority level problems? **Done**
    * Now whenever reCAPTCHA blocks spam through failure of CAPTCHA solution, comment isn't reported to Akismet and added to the spam queue anyways, as it used to happen (_It seems that way at least, after my tests using **viagra-test-123** as outlined [here](http://akismet.com/development/api/)_). It was indeed a hook priority problem, set hook level to 0 since Akismet is level 1.
  * There is a way to show the CAPTCHA on the registration form. Maybe allow the CAPTCHA to not be shown at all on regular posts in case the user has WP setup so that only registered users can comment. **Done**
  * Add an XHTML 1.0 Strict compliance option with disclaimer. **Done**
    * Had to add an extra argument for the **recaptcha\_get\_html** function in recaptbhalib.php.
  * Add an option to use SSL. **Done**
  * Add ability to choose theme for registration recaptcha. **Done**
  * Show disclaimer at the top of post box saying that users should feel safe posting their email addresses.
  * Make XSS-proof. Apostrophes are allowed in email matching regex for MailHide, can it be used to escape out of Javascript.
### Long Term ###
  * Integrate with Akismet. If Akismet says comment is okay, then bypass reCAPTCHA, else, give another chance with reCAPTCHA: Might be possible with Akismet API given Akismet conflicts are fixed
  * Karma model. If, based on karma model, user can be trusted, don't show reCAPTCHA to them.