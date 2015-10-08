**Important: this method is not officially supported and may break when new versions of reCAPTCHA system will come out.**

**For a full list of themes and how to create your own skin for your widget, go here: http://code.google.com/apis/recaptcha/docs/customization.html**

You can apply CSS styles to the reCAPTCHA widget to change its colors and other visual properties. These instructions show you how.

Set the reCAPTCHA theme to "clean" by adding the following code to your site. The "clean" theme is more neutral than the default one and much easier to integrate with your site's look and feel.
```
<script>
  var RecaptchaOptions = { theme : 'clean' };
</script>
```

Other options are: red, white, blackglass, clean, custom.

Then add the following instructions to your CSS file. Remember to replace **#FF0000** with the colors of your choice.

```
  .recaptchatable .recaptcha_image_cell, #recaptcha_table {
    background-color:#FF0000 !important; // reCAPTCHA widget background color
  }
  
  #recaptcha_table {
    border-color: #FF0000 !important; // reCAPTCHA widget border color
  }
  
  #recaptcha_response_field {
    border-color: #FF0000 !important; // Text input field border color
    background-color: #FF0000 !important; //Text input field background color
  }
```

You can add any other CSS property as well -- check any CSS tutorial for more information.