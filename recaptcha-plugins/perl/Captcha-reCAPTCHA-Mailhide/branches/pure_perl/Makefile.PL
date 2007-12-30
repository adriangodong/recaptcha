use strict;
use warnings;
use ExtUtils::MakeMaker;

eval 'use ExtUtils::MakeMaker::Coverage';

my $crypt;

BEGIN {
    my @crypt_opt = qw( Crypt::Rijndael2 Crypt::Rijndael_PP );
    for ( @crypt_opt ) {
        if ( eval "require $_" ) {
            $crypt = $_;
            last;
        }
    }
    $crypt ||= shift @crypt_opt;
}

print "Using $crypt\n";

WriteMakefile(
    ( MM->can( 'signature_target' ) ? ( SIGN => 1 ) : () ),
    NAME          => 'Captcha::reCAPTCHA::Mailhide',
    AUTHOR        => 'Andy Armstrong <andy@hexten.net>',
    LICENSE       => 'perl',
    VERSION_FROM  => 'lib/Captcha/reCAPTCHA/Mailhide.pm',
    ABSTRACT_FROM => 'lib/Captcha/reCAPTCHA/Mailhide.pm',
    PL_FILES      => {},
    PREREQ_PM     => {
        'Test::More'   => 0,
        $crypt         => 0,
        'MIME::Base64' => 0,
        'HTML::Tiny'   => '0.904',
        'Best'         => '0.11',
    },
    dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Captcha-reCAPTCHA-Mailhide-*' },
);
