#!/usr/bin/perl
# Simple CGI Captcha

use strict;
use warnings;
use Captcha::reCAPTCHA;
use Captcha::reCAPTCHA::Mailhide;
use CGI::Simple;

# Your reCAPTCHA keys from
#   https://admin.recaptcha.net/recaptcha/createsite/
use constant PUBLIC_KEY       => '<public key here>';
use constant PRIVATE_KEY      => '<private key here>';

# Your reCAPTCHA mailhide keys from 
#   http://mailhide.recaptcha.net/apikey
use constant MAIL_PUBLIC_KEY  => '<public mailhide key here>';
use constant MAIL_PRIVATE_KEY => '<private mailhide key here>';

$| = 1;

my $q = CGI::Simple->new;
my $c = Captcha::reCAPTCHA->new;
my $m = Captcha::reCAPTCHA::Mailhide->new;

my $error = undef;

print "Content-type: text/html\n\n";
print <<EOT;
<html>
  <body>
    <form action="" method="post">
EOT

# Check response
if ( $q->param( 'recaptcha_response_field' ) ) {
    my $result = $c->check_answer(
        PRIVATE_KEY, $ENV{'REMOTE_ADDR'},
        $q->param( 'recaptcha_challenge_field' ),
        $q->param( 'recaptcha_response_field' )
    );

    if ( $result->{is_valid} ) {
        print "Yes!";
    }
    else {
        $error = $result->{error};
    }
}

# Generate the form
print $c->get_html( PUBLIC_KEY, $error );

print <<EOT;
    <br/>
    <input type="submit" value="submit" />
    </form>
EOT

# Output a protected email address
print "<p>Mail ",
  $m->mailhide_html( MAIL_PUBLIC_KEY, MAIL_PRIVATE_KEY, 'someone@example.com' ), "</p>\n";

print <<EOT;
  </body>
</html>
EOT
