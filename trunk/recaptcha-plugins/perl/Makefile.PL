use strict;
use warnings;
use ExtUtils::MakeMaker;

eval 'use ExtUtils::MakeMaker::Coverage';
warn "Optional ExtUtils::MakeMaker::Coverage not available\n" if $@;

WriteMakefile(
    ( MM->can( 'signature_target' ) ? ( SIGN => 1 ) : () ),
    NAME          => 'Captcha::reCAPTCHA',
    AUTHOR        => 'Andy Armstrong <andy@hexten.net>',
    LICENSE       => 'perl',
    VERSION_FROM  => 'lib/Captcha/reCAPTCHA.pm',
    ABSTRACT_FROM => 'lib/Captcha/reCAPTCHA.pm',
    PL_FILES      => {},
    PREREQ_PM     => {
        'Test::More'      => 0,
        'version'         => 0,
        'LWP::UserAgent'  => 0,
        'Crypt::Rijndael' => 0,
        'MIME::Base64'    => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Captcha-reCAPTCHA-*' },
);
