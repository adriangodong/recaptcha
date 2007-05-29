package Captcha::reCAPTCHA;

use warnings;
use strict;
use Carp;
use LWP::UserAgent;
use Crypt::Rijndael;
use MIME::Base64;

use version; our $VERSION = qv( '0.6' );

use constant API_SERVER          => 'http://api.recaptcha.net';
use constant API_SECURE_SERVER   => 'https://api-secure.recaptcha.net';
use constant API_VERIFY_SERVER   => 'http://api-verify.recaptcha.net';
use constant API_MAILHIDE_SERVER => 'http://mailhide.recaptcha.net';

# TODO: Find out whether there's a proper code for a server error.
use constant SERVER_ERROR => 'recaptcha-not-reachable';

my %ENT_MAP = (
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
    '"' => '&quot;',
    "'" => '&apos;',
);

my %JSON_ESCAPE = (
    '"'  => '\"',
    "\n" => '\n',
    "\t" => '\t',
    "\r" => '\r',
);

sub _hash_re {
    my $hash = shift;
    my $match = join( '|', map quotemeta, sort keys %$hash );
    return qr/($match)/;
}

my $ENT_RE  = _hash_re( \%ENT_MAP );
my $JSON_RE = _hash_re( \%JSON_ESCAPE );

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->_initialize( @_ );
    return $self;
}

sub _initialize {
    my $self = shift;
    my $args = shift || {};

    croak "new must be called with a reference to a hash of parameters"
      unless 'HASH' eq ref $args;
}

# Key validation hook. Currently unused
sub _check_key {
    my ( $type, $key ) = @_;
    return $key;
}

# Get a UA singleton
sub _get_ua {
    my $self = shift;
    $self->{ua} ||= LWP::UserAgent->new();
    return $self->{ua};
}

# URL encode a string
sub _encode_url {
    my $str = shift;
    $str =~ s/([^A-Za-z0-9_])/$1 eq ' ' ? '+' : sprintf("%%%02x", ord($1))/eg;
    return $str;
}

# Turn a hash reference into a query string.
sub _encode_query {
    my $hash = shift || {};
    return join '&',
      map { _encode_url( $_ ) . '=' . _encode_url( $hash->{$_} ) }
      sort keys %$hash;
}

# (X)HTML entity encode a string
sub _encode_entity {
    my $str = shift;
    $str =~ s/$ENT_RE/$ENT_MAP{$1}/eg;
    return $str;
}

# Generate an opening (X)HTML tag
sub _open_tag {
    my $name   = shift;
    my $attr   = shift || {};
    my $closed = shift;

    return "<$name"
      . join( '',
        map { ' ' . $_ . '="' . _encode_entity( $attr->{$_} ) . '"' }
          sort keys %$attr )
      . ( $closed ? ' />' : '>' );
}

# Generate a closing (X)HTML tag
sub _close_tag {
    my $name = shift;
    return "</$name>";
}

# Minimal JSON encoder
sub _json_lite {
    my $obj = shift;
    if ( my $type = ref $obj ) {
        if ( 'HASH' eq $type ) {
            return '{'
              . join( ',',
                map { _json_lite( $_ ) . ':' . _json_lite( $obj->{$_} ) }
                  sort keys %$obj )
              . '}';
        }
        elsif ( 'ARRAY' eq $type ) {
            return '[' . join( ',', map { _json_lite( $_ ) } @$obj ) . ']';
        }
        else {
            croak "Can't convert a $type to JSON";
        }
    }
    else {
        if ( $obj =~ /^-?\d+(?:[.]\d+)?$/ ) {
            return $obj;
        }
        else {
            $obj =~ s/$JSON_RE/$JSON_ESCAPE{$1}/eg;
            return '"' . $obj . '"';
        }
    }
}

sub get_options_setter {
    my $self = shift;
    my $options = shift || return '';
    return join( '',
        _open_tag( 'script', { type => 'text/javascript' } ),
        "\n//<![CDATA[\n",
        "var RecaptchaOptions = ",
        _json_lite( $options ),
        ";\n",
        "//]]>\n",
        _close_tag( 'script' ),
        "\n" );
}

sub get_html {
    my $self = shift;
    my ( $pubkey, $error, $use_ssl, $options ) = @_;

    croak
      "To use reCAPTCHA you must get an API key from http://recaptcha.net/api/getkey"
      unless $pubkey;

    _check_key( 'MAIN_KEY', $pubkey );

    my $server = $use_ssl ? API_SECURE_SERVER : API_SERVER;

    my $query = { k => $pubkey };
    $query->{error} = $error if $error;
    my $qs = _encode_query( $query );

    return join(
        '',
        $self->get_options_setter( $options ),
        _open_tag(
            'script',
            {
                type => 'text/javascript',
                src  => "$server/challenge?$qs",
            }
        ),
        _close_tag( 'script' ),
        "\n",
        _open_tag( 'noscript' ),
        _open_tag(
            'iframe',
            {
                src         => "$server/noscript?$qs",
                height      => 300,
                width       => 500,
                frameborder => 0
            }
        ),
        _close_tag( 'iframe' ),
        _open_tag(
            'textarea',
            { name => 'recaptcha_challenge_field', rows => 3, cols => 40 }
        ),
        _close_tag( 'textarea' ),
        _open_tag(
            'input',
            {
                type  => 'hidden',
                name  => 'recaptcha_response_field',
                value => 'manual_challenge'
            },
            1
        ),
        _close_tag( 'noscript' ),
        "\n"
    );
}

sub _post_request {
    my $self = shift;
    my ( $url, $args ) = @_;

    return $self->_get_ua->post( $url, $args );
}

sub check_answer {
    my $self = shift;
    my ( $privkey, $remoteip, $challenge, $response ) = @_;

    croak
      "To use reCAPTCHA you must get an API key from http://recaptcha.net/api/getkey"
      unless $privkey;

    _check_key( 'MAIN_KEY', $privkey );

    croak "For security reasons, you must pass the remote ip to reCAPTCHA"
      unless $remoteip;

    return { is_valid => 0, error => 'incorrect-challenge-sol' }
      unless $challenge && $response;

    my $resp = $self->_post_request(
        API_VERIFY_SERVER . '/verify',
        {
            privatekey => $privkey,
            remoteip   => $remoteip,
            challenge  => $challenge,
            response   => $response
        }
    );

    if ( $resp->is_success ) {
        my ( $answer, $message ) = split( /\n/, $resp->content, 2 );
        if ( $answer =~ /true/ ) {
            return { is_valid => 1 };
        }
        else {
            chomp $message;
            return { is_valid => 0, error => $message };
        }
    }
    else {
        return { is_valid => 0, error => SERVER_ERROR };
    }
}

sub _aes_encrypt {
    my ( $val, $ky ) = @_;

    my $val_len = length( $val );
    my $pad_len = int( ( $val_len + 15 ) / 16 ) * 16;

    # Pad value
    $val .= chr( 16 - $val_len % 16 ) x ( $pad_len - $val_len )
      if $val_len < $pad_len;

    my $cipher = Crypt::Rijndael->new( $ky, Crypt::Rijndael::MODE_CBC );
    $cipher->set_iv( "\0" x 16 );

    return $cipher->encrypt( $val );
}

sub _urlbase64 {
    my $str = shift;
    chomp( my $enc = encode_base64( $str ) );
    $enc =~ tr{+/}{-_};
    return $enc;
}

sub mailhide_url {
    my $self = shift;
    my ( $pubkey, $privkey, $email ) = @_;

    croak "To use reCAPTCHA Mailhide, you have to sign up for a public and "
      . "private key. You can do so at http://mailhide.recaptcha.net/apikey."
      unless $pubkey && $privkey;

    _check_key( 'MAILHIDE_PUBLIC',  $pubkey );
    _check_key( 'MAILHIDE_PRIVATE', $privkey );

    croak "You must supply an email address"
      unless $email;

    return API_MAILHIDE_SERVER . '/d?'
      . _encode_query(
        {
            k => $pubkey,
            c => _urlbase64( _aes_encrypt( $email, pack( 'H*', $privkey ) ) )
        }
      );
}

sub _email_parts {
    my ( $user, $dom ) = split( /\@/, shift, 2 );
    my $ul = length( $user );
    return ( substr( $user, 0, $ul <= 4 ? 1 : $ul <= 6 ? 3 : 4 ), '...', '@',
        $dom );
}

sub mailhide_html {
    my $self = shift;
    my ( $pubkey, $privkey, $email ) = @_;

    my $url = $self->mailhide_url( $pubkey, $privkey, $email );
    my ( $user, $dots, $at, $dom ) = _email_parts( $email );

    my %window_options = (
        toolbar    => 0,
        scrollbars => 0,
        location   => 0,
        statusbar  => 0,
        menubar    => 0,
        resizable  => 0,
        width      => 500,
        height     => 300
    );

    my $options = join ',',
      map { "$_=$window_options{$_}" } sort keys %window_options;

    return join(
        '',
        _encode_entity( $user ),
        _open_tag(
            'a',
            {
                href    => $url,
                onclick => "window.open('$url', '', '$options'); return false;",
                title   => 'Reveal this e-mail address'
            }
        ),
        $dots,
        _close_tag( 'a' ),
        $at,
        _encode_entity( $dom )
    );
}

1;
__END__

=head1 NAME

Captcha::reCAPTCHA - A Perl implementation of the reCAPTCHA API

=head1 VERSION

This document describes Captcha::reCAPTCHA version 0.6

=head1 SYNOPSIS

    use Captcha::reCAPTCHA;

    my $c = Captcha::reCAPTCHA->new;

    # Output form
    print $c->get_html( 'your public key here' );

    # Verify submission
    my $result = $c->check_answer(
        'your private key here', $ENV{'REMOTE_ADDR'},
        $challenge, $response
    );

    if ( $result->{is_valid} ) {
        print "Yes!";
    }
    else {
        # Error
        $error = $result->{error};
    }

For complete examples see the /examples subdirectory

=head1 DESCRIPTION

reCAPTCHA is a hybrid mechanical turk and captcha that allows visitors
who complete the captcha to assist in the digitization of books.

From L<http://recaptcha.net/learnmore.html>:

    reCAPTCHA improves the process of digitizing books by sending words that
    cannot be read by computers to the Web in the form of CAPTCHAs for
    humans to decipher. More specifically, each word that cannot be read
    correctly by OCR is placed on an image and used as a CAPTCHA. This is
    possible because most OCR programs alert you when a word cannot be read
    correctly.

This Perl implementation is modelled on the PHP interface that can be
found here:

L<http://recaptcha.net/plugins/php/>

=head1 INTERFACE

=over

=item C<< new >>

Create a new C<< Captcha::reCAPTCHA >>.

=back

=head2 reCAPTCHA

To use reCAPTCHA you need to register your site here:

L<https://admin.recaptcha.net/recaptcha/createsite/>

=over

=item C<< get_html( $pubkey, $error, $use_ssl, $options ) >>

Generates HTML to display the captcha.

    print $captcha->get_html( $PUB, $err );

=over

=item C<< $pubkey >>

Your reCAPTCHA public key, from the API Signup Page

=item C<< $error >>

Optional. If this string is set, the reCAPTCHA area will display the error code
given. This error code comes from $response->{error}.

=item C<< $use_ssl >>

Optional. Should the SSL-based API be used? If you are displaying a page
to the user over SSL, be sure to set this to true so an error dialog
doesn't come up in the user's browser.

=item C<< $options >>

Optional. A reference to a hash of options for the captcha. See 
C<< get_options_setter >> for more details.

=back

Returns a string containing the HTML that should be used to display
the captcha.

=item C<< get_options_setter( $options ) >>

You can optionally customize the look of the reCAPTCHA widget with some
JavaScript settings. C<get_options_setter> returns a block of Javascript
wrapped in <script> .. </script> tags that will set the options to be used
by the widget.

C<$options> is a reference to a hash that may contain the following keys:

=over

=item C<theme>

Defines which theme to use for reCAPTCHA. Possible values are 'red',
'white' or 'blackglass'. The default is 'red'.

=item C<tabindex>

Sets a tabindex for the reCAPTCHA text box. If other elements in the
form use a tabindex, this should be set so that navigation is easier for
the user. Default: 0.

=back

=item C<< check_answer >>

After the user has filled out the HTML form, including their answer for
the CAPTCHA, use C<< check_answer >> to check their answer when they
submit the form. The user's answer will be in two form fields,
recaptcha_challenge_field and recaptcha_response_field. The reCAPTCHA
library will make an HTTP request to the reCAPTCHA server and verify the
user's answer.

=over

=item C<< $privkey >>

Your reCAPTCHA private key, from the API Signup Page.

=item C<< $remoteip >>

The user's IP address, in the format 192.168.0.1.

=item C<< $challenge >>

The value of the form field recaptcha_challenge_field

=item C<< $response >>

The value of the form field recaptcha_response_field.

=back

Returns a reference to a hash containing two fields: C<is_valid>
and C<error>.

    my $result = $c->check_answer(
        'your private key here', $ENV{'REMOTE_ADDR'},
        $challenge, $response
    );

    if ( $result->{is_valid} ) {
        print "Yes!";
    }
    else {
        # Error
        $error = $result->{error};
    }

See the /examples subdirectory for examples of how to call C<check_answer>.

=back

=head2 reCAPTCHA Mailhide

To use reCAPTCHA Mailhide you need to get a public, private key pair
from this page:

L<http://mailhide.recaptcha.net/apikey>

The Mailhide API consists of two methods C<< mailhide_html >>
and C<< mailhide_url >>. The methods have the same parameters.

The _html version returns HTML that can be directly put on your web
page. The username portion of the email that is passed in is
truncated and replaced with a link that calls Mailhide. The _url
version gives you the url to decode the email and leaves it up to you
to place the email in HTML.

=over

=item C<< mailhide_url( $pubkey, $privkey, $email ) >>

Generate a link that will decode the specified email address.

=over

=item C<< $pubkey >>

The Mailhide public key from the signup page

=item C<< $privkey >>

The Mailhide private key from the signup page

=item C<< $email >>

The email address you want to hide.

=back

Returns a URL that when clicked will allow the user to decode the hidden
email address.

=item C<< mailhide_html( $pubkey, $privkey, $email ) >>

Generates HTML markup to embed a Mailhide protected email address
on a page.

The arguments are the same as for C<mailhide_url>.

Returns a string containing HTML that may be embedded directly in
a web page.

=back

=head1 CONFIGURATION AND ENVIRONMENT

Captcha::reCAPTCHA requires no configuration files or environment
variables.

To use reCAPTCHA sign up for a key pair here:

L<https://admin.recaptcha.net/recaptcha/createsite/>

To use Mailhide get a public/private key pair here:

L<http://mailhide.recaptcha.net/apikey>

=head1 DEPENDENCIES

LWP::UserAgent,
Crypt::Rijndael,
MIME::Base64,

=head1 INCOMPATIBILITIES

None reported .

=head1 BUGS AND LIMITATIONS

Doesn't currently implement Mailhide support.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-captcha-recaptcha@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Andy Armstrong  C<< <andy@hexten.net> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Andy Armstrong C<< <andy@hexten.net> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
