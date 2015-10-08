# Integration #

## Can I use reCAPTCHA in static HTML files? ##

Not if all you have are static HTML files - you require a server-side scripting language to verify the reCAPTCHA after it has been submitted by your users. This verification cannot be done in static HTML using Javascript or any other client-side language.

If you want reCAPTCHA you require either knowledge of a server-side language or a web application (examples of both may be found at http://code.google.com/apis/recaptcha/intro.html) and a hosting provider that will allow you to use it.

## Can I internationalise the reCAPTCHA challenge itself? ##

Not yet. It is being looked into, however.

# Non-Javascript #

## I'm testing non-JS version and getting "You are at this page because..." ##

If you are getting the message:

_You are at this page because you loaded the JavaScript free version of reCAPTCHA, but it looks like you have JavaScript. We need to prevent this for security reasons. If you are testing out the JavaScript-free version, turn off JavaScript in your browser._

it means that reCAPTCHA has detected that your browser can handle some Javascript, but for some reason will not accept reCAPTCHA. This is typical of using (e.g.) NoScript in Firefox to selectively disable JS on a site by site basis.

Follow the instructions in the message and turn off JS **totally** in your browser for the duration of your testing.

Do not assume that turning off JS means simply doing this (in IE6 and IE7):  Tools > Internet Options > Security > Custom level > Scripting > Active scripting > Disable.  By default, this will only turn off JS in your Intranet zone, which means that the page containing the recaptcha widget will have JS turned off; but the page loaded into the iframe between the noscript tags will still have JS turned on, hence you will get the above-mentioned message.

To turn off JS **totally** in this case, select the Internet zone (under Tools > Internet Options > Security) and then choose Custom level > Scripting > Active scripting > Disable as was done for the Intranet zone.

# Troubleshooting #

## It's not working! Help! ##

Before doing anything else, make sure you're using the correct keys. Are your public and private keys swapped? Did you remember to put the private key in the form handler as well as putting the public key in the form?

Note that Mailhide uses **different keys** from the main form-based reCAPTCHA.

Be sure that your form uses the POST method, or else change the reCAPTCHA form handler variables to GET instead of POST.

## I keep getting "verify-params-incorrect" when developing with Windows Vista ##

Vista defaults to IPV6 for localhost and the IP of the browser on localhost will be sent to reCAPTCHA as "0:0:0:0:0:0:0:1".  You must test for this and change it to "127.0.0.1" during development.

## reCAPTCHA is accepting incorrect words ##

reCAPTCHA consists of two words: a **verification** word, to which the reCAPTCHA server knows the answer and a **read** word which comes from an old book. The read word is not graded (since the server is using human guesses to figure out the answer). As such, this word can be entered incorrectly, and the CAPTCHA will still be valid. Each read word is sent to multiple people, so incorrect solutions will not affect the output of reCAPTCHA.

On the verification word, reCAPTCHA intentionally allows an "off by one" error depending on how much we trust the user giving the solution. This increases the user experience without impacting security. reCAPTCHA engineers monitor this functionality for abuse.

## reCAPTCHA accepts anything I type ##

You probably aren't validating the reCAPTCHA with the API servers.

## I keep getting "incorrect-captcha-sol" even though I'm entering the correct words ##

You are _probably_ not passing in the user's input into the verification routine because you're not getting them from the previous step. You should be ensuring the contents of (in PHP, other languages may differ in syntax) `$_POST['recaptcha_response_field']` and `$_POST['recaptcha_challenge_field']` [are not empty or null](http://code.google.com/apis/recaptcha/docs/tips.html) before calling the verification routine anyway.

Reasons this may be happening include:
  * You are expecting the input to come from `POST`, but your input form specifies the `method` as `GET` (or you've not specified it at all, in which case it will default to `GET`)
  * You have placed your input `<form>` in a `<table>` (the table should be in the form) in your input code
  * You have typo'd either of the `POST` variables in your verification code.

When posting about this problem to the list, please supply the output of the following (PHP - provide similar for other languages please) debug code which should go directly before any call to `recaptcha_check_answer()` or any other call that submits the entered input for verification:

```
<?php
echo "<pre> _POST: =========\n";
print_r($_POST);
echo "\n=========\n</pre>";
?>
```

Example output from the above on a form that also has a user, two password entries and an email:
```
 _POST: =========
Array
(
    [user] => asdfghjk
    [password] => asdf
    [password2] => asdf
    [email] => 
    [recaptcha_challenge_field] => 03AHJ_VuvGHdNKNYZCZt_MJ6EDiDNdorrvARpUiuQ2OjZ4y2zR_ejuRGW5zPGPaHVDg_sywkAuA3rsMKoKNjMzUvNjxWAs8G8DBVexQKuKanfvFIt0uFj2LfEU6KKwHNDONM_MJpn01fBHnRxhhvHwbt4fL__7Q_dmvA
    [recaptcha_response_field] => jerespe zollner:
)

=========
```

The last two elements shown above should be (a) present and (b) have values.

## I'm getting certificate errors for api-secure.recaptcha.net ##

The recaptcha.net domain was deprecated back in [June 2010](http://groups.google.com/group/recaptcha/browse_thread/thread/7a4839d13ac3dcf5/a51be72cd56c1461), and finally obsoleted starting in [April 2011](http://groups.google.com/group/recaptcha/msg/8e88d1199244a778).

As the second link indicates, you need to replace all instances of https://api-secure.recaptcha.net/XXX with https://www.google.com/recaptcha/api/XXX (or update the [plugin](http://code.google.com/p/recaptcha/downloads/list) you're using.)

# Other #

## I can't use `[3rd party site]` because of reCAPTCHA / I don't like entering captchas ##

This group is not for you. No-one on this group is likely to have any influence with an implementation using reCAPTCHA on a site which neither you, nor anyone on the group, is directly responsible for. reCAPTCHA only provides captcha functionality - with little to no control of the circumstances under which it is used.

If your responses appear consistently wrong, even though you think they should be correct, please try the test form at http://www.google.com/recaptcha/learnmore and ensure that you're using it correctly. If that one works, then there is probably a problem with the 3rd party site and how they've implemented it.

Look for a 'Contact us' link on the website you have an issue with, and contact the site owners directly. Complaining on the group will solve nothing.

General complaints about the readability of the images will largely go ignored, since most of the people who reply on this group are volunteers who happen to use reCAPTCHA, and are willing to give up some time to help others who have genuine problems with implementing the functionality. As a result most members have no influence over how the images are generated, and posting abusive messages will achieve nothing.

If you have a genuine complaint about the images, please [contact reCAPTCHA support directly](http://www.google.com/recaptcha/mailhide/d?k=01eCb_oqwCAH1vvF73hZe7Vg==&c=doBhwIV8aV9QmbjHdFn7jCe0964y2gkHx9qGj8byHMo=); do not post to the group please.

## I'm still getting spam on my website! ##
reCAPTCHA is only designed to prevent automated spam attacks - i.e. only those started and completed by software. It cannot prevent spam generated by people typing at a keyboard.

There are other packages/APIs out there that can help mitigate these when used _in addition_ to reCAPTCHA (quoted text taken directly from the relevant websites):

  * [Bad Behavior](http://bad-behavior.ioerror.us/)
    * Bad Behavior complements other link spam solutions by acting as a gatekeeper, preventing spammers from ever delivering their junk, and in many cases, from ever reading your site in the first place. This keeps your site’s load down, makes your site logs cleaner, and can help prevent denial of service conditions caused by spammers.
  * [Stop Forum Spam](http://www.stopforumspam.com/)
    * We provide a "free for use" site where you can check registrations and posts against our database. We list known forum and blog spammers, including IP and email addresses, usernames, how busy they are and, in some cases, evidence of their spam.
  * [Project Honeypot](http://www.projecthoneypot.org/home.php)
    * Project Honey Pot tracks harvesters, comment spammers, and other suspicious visitors to websites. Http:BL makes this data available to any member of Project Honey Pot in an easy and efficient way.
  * [OSSEC](http://www.ossec.net/)
    * OSSEC is an Open Source Host-based Intrusion Detection System. It performs log analysis, file integrity checking, policy monitoring, rootkit detection, real-time alerting and active response.
## Can I delete a key/all keys/a site/my account? ##

Yes, you can -- go to https://www.google.com/recaptcha/admin, choose a key, and click "Delete these keys". There's no way to undo a deletion, so make sure you choose the right set of keys!

Alternatively, you can simply stop using those keys. Yours is the only site that can use those keys, and no one else can use them.  Leaving these extra keys on the system does no harm.