**Note: this documentation is a community-supported, unofficial version of the official docs, and may be out of date or incorrect in parts. The official docs are located at: https://developers.google.com/recaptcha/intro**

reCAPTCHA is a free CAPTCHA service that helps protect your site against spam, malicious registrations and other forms of attacks where computers try to disguise themselves as a human. reCAPTCHA comes in the form of a widget that you can easily add to your blog, forum, registration, etc. Below you can find instructions on how to add reCAPTCHA to your site.



# Part 1: Sign Up #

First, you'll need to [sign up](https://www.google.com/recaptcha/admin) and create reCAPTCHA keys for your site.

The keys are unique to your domain and sub-domains and will not work for other domains unless you:
  * Sign up for multiple keys (one for each site)
  * Create a global key by checking the box for "Enable this key on all domains (global key)"

For example:
  * The keys for **test.com** will work on **a.test.com**, **b.test.com**, **c.test.com** and any other sub-domains.
  * If the option "Enable this key on all domains (global key)" is checked, the keys will work on **a.test.com**, **x.com**, **y.com** and any other domains or sub-domains.

# Part 2: Installation #
Installation consists of two steps and optionally a third step where you customize the widget:

  1. Client Side: Displaying the reCAPTCHA Widget (Required)
  1. Server Side: Verifying the solution (Required)
  1. Customizations (Optional)

In most Web forms, you usually have two files: the form itself with the fields and the file with the script to process the inputs to the form. These two files correspond to steps 1 and 2 above. Therefore, in most cases you will have to modify two different files.

Displaying the reCAPTCHA widget is the simpler step. You can usually display it using an application plugin (recommended; see below), or alternatively by adding the javascript below inside your `<form>` element (a third option, discussed later, is to use the AJAX API.)

```
 <script type="text/javascript"
   src="https://www.google.com/recaptcha/api/challenge?k=YOUR_PUBLIC_KEY"
 </script>
 <noscript>
   <iframe src="https://www.google.com/recaptcha/api/noscript?k=YOUR_PUBLIC_KEY"
       height="300" width="500" frameborder="0"></iframe><br>
 </noscript>
```

You need to replace the two instances of YOUR\_PUBLIC\_KEY with the public key that you received during the account creation process (part 1 above). Be careful that you don't use your private key by mistake.

Verifying the solution is a bit more difficult, and usually requires modifying a script. If you're using one of the following programming environments or applications, use these resources and instructions:

**Programming Environments:**

  * [PHP](#PHP.md)
  * [ASP.NET](#ASP.NET.md)
  * [Classic ASP](#Classic_ASP.md) (contributed by Mark Short)
  * [Java/JSP](#Java/JSP.md)
  * [Perl](#Perl.md)
  * [Python](http://python.org/pypi/recaptcha-client)
  * [Ruby](http://www.loonsoft.com/recaptcha/) (contributed by McClain Looney)
  * Another [Ruby](http://github.com/ambethia/recaptcha/) library from Jason L Perry
  * [JSP Mailhide Tag](http://code.google.com/p/mailhide-tag/) (contributed by Tamas Magyar)
  * [ColdFusion](http://recaptcha.riaforge.org/) (contributed by Robin Hilliard)
  * [WebDNA](http://www.danstrong.com/reCAPTCHA-WebDNA.html) (contributed by Dan Strong)

**Applications:**

  * [WordPress](http://code.google.com/apis/recaptcha/docs/wordpress.html)
  * [MediaWiki](http://code.google.com/apis/recaptcha/docs/mediawiki.html)
  * [phpBB](http://code.google.com/apis/recaptcha/docs/phpbb.html)
  * [FormMail](#FormMail.md)
  * [Movable Type](http://multipart-mixed.com/software/recaptcha.html) (contributed by Josh Carter)
  * [Drupal](http://drupal.org/project/recaptcha) (contributed by Rob Loach)
  * [Symfony](http://trac.symfony-project.com/trac/wiki/sfReCaptchaPlugin) (contributed by Arthur Koziel)
  * [TYPO3](http://typo3.org/extensions/repository/view/jm_recaptcha/current/) (maintained by Markus Blaschke, contributed by Jens Mittag. See also the [example](http://typo3.org/extensions/repository/view/jm_recaptcha_example/current/) of using the plugin)
  * [NucleusCMS](http://lordmatt.co.uk/item/812/) (contributed by Matt)
  * [vBulletin](http://www.vbulletin.org/forum/showthread.php?t=151824) (contributed by Magnus)
  * [Joomla](http://extensions.joomla.org/component/option,com_mtree/task,viewlink/link_id,2866/Itemid,35/) (contributed by Robert van den Breemen)
  * [JSP Mailhide](http://code.google.com/p/mailhide-tag/) (by Tamas Magyar)
  * [bbPress](http://www.gospelrhys.co.uk/plugins/bbpress-plugins/recaptcha-bbpress-plugin) (by Rhys Wynne)
  * [WebGUI](http://www.webgui.org/wiki/enabling-recaptcha)

**Otherwise:**

  * [The DIY installation](http://code.google.com/apis/recaptcha/intro.html) requires you to write code to communicate with reCAPTCHA servers to verify the solution.

## PHP ##

Download the [reCAPTCHA PHP library](http://code.google.com/p/recaptcha/downloads/list?q=label:phplib-Latest). You will only need one file from there (recaptchalib.php). The other files are examples, readme and legal stuff -- they don't affect functionality.

### Client Side (How to make the CAPTCHA image show up) ###
If you want to use the PHP library to display the reCAPTCHA widget, you'll need to insert this snippet of code inside the `<form>` element where the reCAPTCHA widget will be placed:

```
  require_once('recaptchalib.php');
  $publickey = "YOUR_PUBLIC_KEY"; // You got this from the signup page.
  echo recaptcha_get_html($publickey);
```

With the code, your form might look something like this:

```
<!-- your HTML content -->
 <form method="post" action="verify.php">
   <?php
     require_once('recaptchalib.php');
     $publickey = "YOUR_PUBLIC_KEY"; // you got this from the signup page
     echo recaptcha_get_html($publickey);
   ?>
   <input type="submit" />
 </form><br>
<!-- more of your HTML content -->
```

Don't forget to set $publickey by replacing YOUR\_PUBLIC\_KEY with the value you obtained in Part 1 above.

Note that the value of the "action" attribute is "verify.php". Now, verify.php is the destination file in which the values of this form are submitted to. So you will need a file verify.php in the same location as the client html.

The require\_once function in the example above expects recaptchalib.php to be in the same directory as your form file. If it is in another directory, you must link it appropriately. For example if your recaptchalib.php is in the directory called 'captcha' that is on the same level as your form file, the function will look like this: require\_once('captcha/recaptchalib.php').

Also make sure your form is set to get the form variables using `$_POST`, instead of `$_REQUEST`, and that the form itself is using the POST method.

### Server Side (How to test if the user entered the right answer) ###

The following code should be placed at the top of the verify.php file:

```
 <?php
 require_once('recaptchalib.php');
 $privatekey = "YOUR_PRIVATE_KEY";
 $resp = recaptcha_check_answer ($privatekey,
                                 $_SERVER["REMOTE_ADDR"],
                                 $_POST["recaptcha_challenge_field"],
                                 $_POST["recaptcha_response_field"]);
 if (!$resp->is_valid) {
   // What happens when the CAPTCHA was entered incorrectly
   die ("The reCAPTCHA wasn't entered correctly. Go back and try it again." .
        "(reCAPTCHA said: " . $resp->error . ")");
 } else {
   // Your code here to handle a successful verification
 }
 ?>
```

In the code above:
  * `recaptcha_check_answer` returns an object that represents whether the user successfully completed the challenge.
  * If `$resp->is_valid` is true then the captcha challenge was correctly completed and you should continue with form processing.
  * If `$resp->is_valid` is false then the user failed to provide the correct captcha text and you should redisplay the form to allow them another attempt. In this case `$resp->error` will be an error code that can be provided to `recaptcha_get_html`. Passing the error code makes the reCAPTCHA control display a message explaining that the user entered the text incorrectly and should try again.

Notice that this code is asking for the **private** key, which should not be confused with the public key. You get that from the same page as the public key.

That's it! reCAPTCHA should now be working on your site.

## ASP.NET ##

  * Download the [reCAPTCHA ASP.NET library](http://code.google.com/p/recaptcha/downloads/list?q=label:aspnetlib-Latest).
  * Add a reference on your website to library/bin/Release/Recaptcha.dll: On the Visual Studio Website menu, choose Add Reference and then click the .NET tab in the dialog box. Select the Recaptcha.dll component from the list of .NET components and then click OK. If you don't see the component, click the Browse tab and look for the assembly file on your hard drive.
  * Insert the reCAPTCHA control into the form you wish to protect by adding the following code snippets:

  * At the top of the aspx page, insert this:

```
 <%@ Register TagPrefix="recaptcha" Namespace="Recaptcha" Assembly="Recaptcha" %>
```

  * Then insert the reCAPTCHA control inside of the `<form runat="server">` tag:

```
 <recaptcha:RecaptchaControl
   ID="recaptcha"
   runat="server"
   PublicKey="<font color=red>your_public_key</font>"            
   PrivateKey="<font color=red>your_private_key</font>"
   />
```
  * You will need to substitute your public and private key into PublicKey and PrivateKey respectively.
  * Make sure you use ASP.NET validation to validate your form (you should check Page.IsValid on submission).
  * The following is a "Hello World" with reCAPTCHA using Visual Basic. A C# sample is included with the library download:
```
 <%@ Page Language="VB" %>
 <%@ Register TagPrefix="recaptcha" Namespace="Recaptcha" Assembly="Recaptcha" %>
 <script runat=server>
     Sub btnSubmit_Click(ByVal sender As Object, ByVal e As EventArgs)
         If Page.IsValid Then
             lblResult.Text = "You Got It!"
             lblResult.ForeColor = Drawing.Color.Green
         Else
             lblResult.Text = "Incorrect"
             lblResult.ForeColor = Drawing.Color.Red
         End If
     End Sub
 </script>
 <html>
 <body>
     <form runat="server">
         <asp:Label Visible=false ID="lblResult" runat="server" />   
         <recaptcha:RecaptchaControl
             ID="recaptcha"
             runat="server"
             Theme="red"
             PublicKey="<font color=red>your_public_key</font>"            
             PrivateKey="<font color=red>your_private_key</font>"
             />
         <br />
         <asp:Button ID="btnSubmit" runat="server" Text="Submit" OnClick="btnSubmit_Click" />
     </form>
 </body>
 </html>
```

## Classic ASP ##

  * Put this code at the top of your ASP page:

```

 <%
 recaptcha_challenge_field  = Request("recaptcha_challenge_field")
 recaptcha_response_field   = Request("recaptcha_response_field")
 recaptcha_public_key       = "<font color=red>your_public_key</font>" ' your public key
 recaptcha_private_key      = "<font color=red>your_private_key</font>" ' your private key
 ' returns the HTML for the widget
 function recaptcha_challenge_writer()
 recaptcha_challenge_writer = _
 "<script type=""text/javascript"">" & _
 "var RecaptchaOptions = {" & _
 "   theme : 'red'," & _
 "   tabindex : 0" & _
 "};" & _
 "</script>" & _
 "<script type=""text/javascript"" src=""http://www.google.com/recaptcha/api/challenge?k=" & recaptcha_public_key & """></script>" & _
 "<noscript>" & _
   "<iframe src=""http://www.google.com/recaptcha/api/noscript?k=" & recaptcha_public_key & """ frameborder=""1""></iframe><br>" & _
     "<textarea name=""recaptcha_challenge_field"" rows=""3""cols=""40""></textarea>" & _
     "<input type=""hidden"" name=""recaptcha_response_field""value=""manual_challenge"">" & _
 "</noscript>"
 end function
 ' returns "" if correct, otherwise it returns the error response
 function recaptcha_confirm(rechallenge,reresponse)
 Dim VarString
 VarString = _
         "privatekey=" & recaptcha_private_key & _
         "&remoteip=" & Request.ServerVariables("REMOTE_ADDR") & _
         "&challenge=" & rechallenge & _
         "&response=" & reresponse
 Dim objXmlHttp
 Set objXmlHttp = Server.CreateObject("Msxml2.ServerXMLHTTP")
 objXmlHttp.open "POST", "http://www.google.com/recaptcha/api/verify", False
 objXmlHttp.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
 objXmlHttp.send VarString
 Dim ResponseString
 ResponseString = split(objXmlHttp.responseText, vblf)
 Set objXmlHttp = Nothing
 if ResponseString(0) = "true" then
   'They answered correctly
    recaptcha_confirm = ""
 else
   'They answered incorrectly
    recaptcha_confirm = ResponseString(1)
 end if
 end function
 server_response = ""
 newCaptcha = True
 if (recaptcha_challenge_field <> "" or recaptcha_response_field <> "") then
   server_response = recaptcha_confirm(recaptcha_challenge_field, recaptcha_response_field)
   newCaptcha = False  
 end if
```

What happens here is the variables "server\_response" and "newCaptcha" are set whenever the page is loaded, allowing you to determine the state of your page.

  * You can use the following HTML as a skeleton:

```
 <html>
 <body>
 <% if server_response <> "" or newCaptcha then %>
   <% if newCaptcha = False then %>
     <!-- An error occurred -->
     Wrong!
   <% end if %>
   <!-- Generating the form -->
   <form action="recaptcha.asp" method="post">
     <%=recaptcha_challenge_writer()%>
   </form>
 <% else %>
   <!-- The solution was correct -->
   Correct!
 <%end if%>
 </body>
 </html>
```

## Java/JSP ##

Download the [reCAPTCHA Java Library here](http://code.google.com/p/recaptcha/downloads/list?q=label:java-Latest) (contributed by Soren) and unzip it. Typically the only thing you'll need is the jar file (recaptcha4j-X.X.X.jar), which you have to copy to a place where it can be loaded by your java application. For example, if you are using Tomcat to run JSP, you may put the jar file in a directory called WEB-INF/lib/.

### Client Side (How to make the CAPTCHA image show up) ###

If you want to use the Java plugin to display the reCAPTCHA widget, you'll need to import the appropriate reCAPTCHA classes. In JSP, you would do this by inserting these lines near the top of the file with the form element where the reCAPTCHA widget will be displayed:

```
<%@ page import="net.tanesha.recaptcha.ReCaptcha" %>
<%@ page import="net.tanesha.recaptcha.ReCaptchaFactory" %>
```

Then, you need to create an instance of reCAPTCHA:

```
ReCaptcha c = ReCaptchaFactory.newReCaptcha("YOUR_PUBLIC_KEY", "YOUR_PRIVATE_KEY", false);
```

Finally, the HTML to display the reCAPTCHA widget can be obtained from the following function call:

```
c.createRecaptchaHtml(null, null)
```

So, in JSP your code may look something like this:

```
   <%@ page import="net.tanesha.recaptcha.ReCaptcha" %>
   <%@ page import="net.tanesha.recaptcha.ReCaptchaFactory" %>
   <html>
     <body>
       <form action="" method="post">
       <%
         ReCaptcha c = ReCaptchaFactory.newReCaptcha("YOUR_PUBLIC_KEY", "YOUR_PRIVATE_KEY", false);
         out.print(c.createRecaptchaHtml(null, null));
       %>
       <input type="submit" value="submit" />
       </form>
     </body>
   </html>
```

Don't forget to replace YOUR\_PUBLIC\_KEY and YOUR\_PRIVATE\_KEY with the values you obtained in Part 1 above.

### Server Side (How to test if the user entered the right answer) ###

In the application that verifies your form, you'll first need to import the necessary reCAPTCHA classes:

```
import net.tanesha.recaptcha.ReCaptchaImpl;
import net.tanesha.recaptcha.ReCaptchaResponse;
```

Next, you need to insert the code that verifies the reCAPTCHA solution entered by the user. The example below (in JSP) shows how this can be done:

```
   <%@ page import="net.tanesha.recaptcha.ReCaptchaImpl" %>
   <%@ page import="net.tanesha.recaptcha.ReCaptchaResponse" %>
   <html>
     <body>
     <%
       String remoteAddr = request.getRemoteAddr();
       ReCaptchaImpl reCaptcha = new ReCaptchaImpl();
       reCaptcha.setPrivateKey("<font color=red>your_private_key</font>");
       String challenge = request.getParameter("recaptcha_challenge_field");
       String uresponse = request.getParameter("recaptcha_response_field");
       ReCaptchaResponse reCaptchaResponse = reCaptcha.checkAnswer(remoteAddr, challenge, uresponse);
       if (reCaptchaResponse.isValid()) {
         out.print("Answer was entered correctly!");
       } else {
         out.print("Answer is wrong");
       }
     %>
     </body>
   </html>
```

In the code above:
  * remoteAddr is the user's IP address (which is passed to the reCAPTCHA servers)
  * uresponse contains the user's answer to the reCAPTCHA challenge.

If you're having trouble, you can also see the following article that explains how to add reCAPTCHA to your Java application: [How to reCAPTCHA Your Java Application](http://wheelersoftware.com/articles/recaptcha-java.html)

### Important: DNS Caching ###

Java has an annoying issue that may cause the connection between your server and reCAPTCHA to be interrupted every few months, and reCAPTCHA will stop working in your site when that happens. Read below to see how to fix this.

By default the Java Virtual Machine (JVM) caches all DNS lookups forever instead of using the time-to-live (TTL) value which is specified in the DNS record of each host. For those of you how do not know it, a DNS lookup is a request sent to a DNS server which converts a readable hostname to an IP address. For example, it converts **www.recaptcha.net** to the IP address **69.12.97.164**.

reCAPTCHA servers can change IP addresses. Because Java caches DNS lookups forever, this can cause the connection between your server and reCAPTCHA to go down when the reCAPTCHA IP address changes. If this happens, restarting your JVM (e.g., restarting Tomcat) can fix the problem because it causes a new DNS lookup. However, you probably don't want to restart your JVM once every few months whenever your site breaks because the reCAPTCHA servers changed IP addresses.

To fix this issue for good, you can pass **-Dsun.net.inetaddr.ttl=30** to your app-server (this tells Java to only cache DNS for 30 seconds). In Tomcat for Windows, this can be done by following the steps below:

  * Stop Tomcat
  * Go to tomcat\bin
  * Run Tomcat5w.exe
  * Go to Java tab
  * Add java property to java options section: -Dsun.net.inetaddr.ttl=30
  * Exit
  * Start Tomcat

[Here is an article](http://www.mattryall.net/blog/2005/03/javas-awful-dns-caching) explaining more about this issue.

## Perl ##

Download the [reCAPTCHA Perl Module](http://search.cpan.org/dist/Captcha-reCAPTCHA/lib/Captcha/reCAPTCHA.pm) (contributed by Andy Armstrong). You will need to install this module on your machine (web server). The module depends on the modules LWP::UserAgent and HTML::Tiny, both of which will also need to be installed. Here are some basic [instructions on installing Perl modules.](http://www.perlmonks.org/index.pl?node_id=128077)

### Client Side (How to make the CAPTCHA image show up) ###

If you want to use the Perl library to display the reCAPTCHA widget, you'll need to insert this line near the top of the file with the form element where the reCAPTCHA widget will be displayed:

```
use Captcha::reCAPTCHA;
```

Then, you need to create an instance of reCAPTCHA:

```
my $c = Captcha::reCAPTCHA->new;
```

Finally, to display the reCAPTCHA widget, you must place the following line inside the `<form>` tag:

```
print $c->get_html("YOUR_PUBLIC_KEY");
```

So, your code may look something like this:

```
use Captcha::reCAPTCHA;
my $c = Captcha::reCAPTCHA->new;
print <<EOT;
<html>
  <body>
    <form action="" method="post">
EOT
print $c->get_html("<font color=red>your_public_key</font>");
print <<EOT;
    <input type="submit" value="submit" />
    </form>
  </body>
</html>
EOT
```

Don't forget to replace YOUR\_PUBLIC\_KEY with the value you obtained in Part 1 above.

### Server Side (How to test if the user entered the right answer) ###

Below is a skeleton of how to verify the reCAPTCHA answer:

```
use Captcha::reCAPTCHA;
my $c = Captcha::reCAPTCHA->new;
my $challenge = the value of param 'recaptcha_challenge_field';
my $response = the value of param 'recaptcha_response_field';
# Verify submission
my $result = $c->check_answer(
    "YOUR_PRIVATE_KEY", $ENV{'REMOTE_ADDR'},
    $challenge, $response
);
if ( $result->{is_valid} ) {
    print "Yes!";
}
else {
    # Error
    print "No";
}
```

## FormMail ##

Here we will explain how to add reCAPTCHA to your FormMail script without using the reCAPTCHA Perl Module. If you know what you're doing, you can alternatively use the reCAPTCHA Perl Module.

### Client Side (How to make the CAPTCHA image show up) ###

In your HTML page, inside the `<form>` element you must add the following code:

```
 <script type="text/javascript"
   src="http://www.google.com/recaptcha/api/challenge?k=YOUR_PUBLIC_KEY">
 </script>
 <noscript>
   <iframe src="http://www.google.com/recaptcha/api/noscript?k=YOUR_PUBLIC_KEY"
       height="300" width="500" frameborder="0"></iframe><br>
   <textarea name="recaptcha_challenge_field" rows="3" cols="40">
   </textarea>
   <input type="hidden" name="recaptcha_response_field" 
       value="manual_challenge">
 </noscript>
```

You need to replace the two instances of YOUR\_PUBLIC\_KEY with the public key that you received during the account creation process (Part 1 above). Be careful that you don't use your private key by mistake.

This will basically add two parameters, which are passed to formmail.cgi (or FormMail.pl) through a POST request, namely:

  * recaptcha\_challenge\_field
    * This is the challenge created through your public key.
  * recaptcha\_response\_field
    * This is the user-submitted response to the challenge above.

### Server Side (How to test if the user entered the right answer) ###

Next, you need to modify formmail.cgi (or FormMail.pl) to handle the two parameters and to validate the challenge from the reCAPTCHA servers. At this point, it's probably a good idea to make a backup copy of your FormMail.pl, just in case. In the code below, "+" means the line needs to be added to the FormMail script, and "-" means the line needs to be removed from it. In every case, we show where the lines need to be added or removed by showing the adjacent lines in the FormMail script.

First, you need to tell Perl to use the module LWP::UserAgent by adding the following line to FormMail:

```
# ACCESS CONTROL FIX: Peter D. Thompson Yezek                                #
#                     http://www.securityfocus.com/archive/1/62033           #
##############################################################################
+use LWP::UserAgent;
```

Now, validate the CAPTCHA response and generate an error if the response doesn't match the challenge.

```
+##############################################################################
+# Check the CAPTCHA response via the reCAPTCHA service.
+sub check_captcha {
+
+      my $ua = LWP::UserAgent->new();
+      my $result=$ua->post(
+      'http://api-verify.recaptcha.net/verify',
+      {
+          privatekey => '<font color=red>your_private_key</font>',
+          remoteip   => $ENV{'REMOTE_ADDR'},
+          challenge  => $Form{'recaptcha_challenge_field'},
+          response   => $Form{'recaptcha_response_field'}
+      });
+
+      if ( $result->is_success && $result->content =~ /^true/) {
+              return;
+      } else {
+              &error('captcha_failed');
+      }
+}
+
# NOTE rev1.91: This function is no longer intended to stop abuse, that      #
#    functionality is now embedded in the checks made on @recipients and the #
#    recipient form field.                                                   #
```

Finally, create the functionality that prints the error message in case the check fails:

```
        if ($Config{'missing_fields_redirect'}) {
            print "Location: " . &clean_html($Config{'missing_fields_redirect'}) . "\n\n";
        }
+    }
+    elsif ($error eq 'captcha_failed') {
+            print <<"(END ERROR HTML)";
+Content-type: text/html
+
+<html>
+ <head>
+  <title>Error: Captcha Check Failed</title>
+ </head>
+ <body bgcolor=#FFFFFF text=#000000>
+ <center>
+  <table border=0 width=600 bgcolor=#9C9C9C>
+    <tr><th><font size=+2>Error: Captcha Check Failed</font></th></tr>
+   </table>
+  <table border=0 width=600 bgcolor=#CFCFCF>
+    <tr><td>The Captcha response of the form you submitted did not match the challenge.
+     Please check the form and make sure that your response matches the challenge in the captcha image.
+     You can use the browser back button to return to the form.
+     </center>
+    </td></tr>
+   </table>
+  </center>
+ </body>
+</html>
+(END ERROR HTML)
+    }
        else {
             foreach $missing_field (@error_fields) {
           $missing_field_list .= "<li>" . &clean_html($missing_field) . "\n";
.
.
.
 </html>
(END ERROR HTML)
        }
-    }
-
    exit;
}
```

That's it! reCAPTCHA should now be working on your site.

# Part 3: Customizing Look and Feel #

Now that you've successfully installed reCAPTCHA on your site, you may want to change the way it looks. There are two ways to do this: (1) choosing one of the standard reCAPTCHA themes, or (2) fully customizing the appearance of reCAPTCHA.

## Standard Themes ##

The first step is to add the following code in your main HTML page anywhere **before** the `<form>` element where reCAPTCHA appears:

```
<script type="text/javascript">
var RecaptchaOptions = {
   theme : 'THEME_NAME'
};
</script>
```

Note: This will not work if it appears after the main script where reCAPTCHA is first invoked.

To use a standard theme, you need to replace THEME\_NAME by one of the following four theme names:
  * red (default theme)
  * white
  * blackglass
  * clean

## Custom Theming ##

To use a fully custom theme, you will need to tell reCAPTCHA that it should not create a user interface of its own. reCAPTCHA will rely on the presence of HTML elements with the following IDs to display the CAPTCHA to the user:

  * An empty div with ID recaptcha\_image. This is where the actual image will be placed. The div will be automatically set to 300x57 pixels.
  * A text input with ID and name both set to recaptcha\_response\_field. This is where the user can enter their answer.
  * A div that contains the entire reCAPTCHA widget. The ID of this div should be placed into the parameter custom\_theme\_widget of RecaptchaOptions, and the style of the div should be set to display:none. After the reCAPTCHA theming code has fully loaded, it will make the div visible. This element avoids making the page flicker while it loads.

To implement all of this this, first place the following code in your main HTML page anywhere before the `<form>` element where reCAPTCHA appears:

```
<script type="text/javascript">
var RecaptchaOptions = {
   theme : 'custom',
   custom_theme_widget: 'recaptcha_widget'
};
</script>
```

Then, inside the `<form>` element where you want reCAPTCHA to appear, place:

```
<div id="recaptcha_widget" style="display:none">
  <div id="recaptcha_image"></div>
  <div class="recaptcha_only_if_incorrect_sol" style="color:red">Incorrect please try again</div>
  <span class="recaptcha_only_if_image">Enter the words above:</span>
  <span class="recaptcha_only_if_audio">Enter the numbers you hear:</span>
  <input type="text" id="recaptcha_response_field" name="recaptcha_response_field" />
  <div><a href="javascript:Recaptcha.reload()">Get another CAPTCHA</a></div>
  <div class="recaptcha_only_if_image"><a href="javascript:Recaptcha.switch_type('audio')">Get an audio CAPTCHA</a></div>
  <div class="recaptcha_only_if_audio"><a href="javascript:Recaptcha.switch_type('image')">Get an image CAPTCHA</a></div>
  <div><a href="javascript:Recaptcha.showhelp()">Help</a></div>
</div>
<script type="text/javascript"
   src="http://www.google.com/recaptcha/api/challenge?k=YOUR_PUBLIC_KEY">
</script>
<noscript>
  <iframe src="http://www.google.com/recaptcha/api/noscript?k=YOUR_PUBLIC_KEY"
       height="300" width="500" frameborder="0"></iframe><br />
  <textarea name="recaptcha_challenge_field" rows="3" cols="40">
  </textarea>
  <input type="hidden" name="recaptcha_response_field"
       value="manual_challenge" />
</noscript>
```

Notice that the last few lines are simply the standard way to display reCAPTCHA explained at the beginning of this document.
Here's what's going on in the code above. The Recaptcha JavaScript object provides methods which allow you to change the state of the CAPTCHA. The method reload displays a new CAPTCHA challenge, and the method switch\_type toggles between image and audio CAPTCHAs. In order to create a full UI for reCAPTCHA, we display different information when the CAPTCHA is in different states. For instance, when the user is viewing an image CAPTCHA, a link to "Get an audio CAPTCHA" is shown.

Four CSS classes are available for you to create a stateful UI:

  * recaptcha\_only\_if\_image, visible when an image CAPTCHA is being displayed
  * recaptcha\_only\_if\_audio, visible when an audio CAPTCHA is being displayed
  * recaptcha\_only\_if\_incorrect\_sol, visible when the previous solution was incorrect
  * recaptcha\_only\_if\_no\_incorrect\_sol, visible when the previous solution was not incorrect

While theming does give you many options, you need to follow some user interface consistency rules:

  * You must state that you are using reCAPTCHA near the CAPTCHA widget.
  * You must provide a visible button that calls the reload function.
  * You must provide a way for visually impaired users to access an audio CAPTCHA.
  * You must provide alt text for any images that you use as buttons in the reCAPTCHA widget.

# Troubleshooting #

For troubleshooting, check out the [official troubleshooting guide](http://code.google.com/apis/recaptcha/docs/troubleshooting.html).

If that doesn't help answer your question, try asking on the public [reCAPTCHA support forum](http://groups.google.com/group/recaptcha).