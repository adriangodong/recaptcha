# Everything is miscellaneous
use strict;
use warnings;
use Test::More tests => 5;
use Captcha::reCAPTCHA;

# Verify that _get_ua works
ok my $captcha = Captcha::reCAPTCHA->new;
my $ua1 = $captcha->_get_ua;
isa_ok $ua1, 'LWP::UserAgent';

my $ua2 = $captcha->_get_ua;
isa_ok $ua2, 'LWP::UserAgent';

is $ua1, $ua2, 'Singleton OK';

# JSON
my $hash = {
    '1'     => 1.23,
    'two'   => [ 'this', 'that', ['other'] ],
    'three' => '"Hello"',
    'four'  => "Newline -> \n"
};

my $json = Captcha::reCAPTCHA::_json_lite($hash);
my $want = '{1:1.23,"four":"Newline -> \\n","three":"\\"Hello\\"","two":["this","that",["other"]]}';
is $json, $want, "JSON OK";
