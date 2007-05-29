use strict;
use warnings;
use Test::More tests => 3;
use Captcha::reCAPTCHA;

use constant PUBKEY  => 'UcV0oq5XNVM01AyYmMNRqvRA==';
use constant PRIVKEY => 'E542D5DB870FF2D2B9D01070FF04F0C8';

ok my $captcha = Captcha::reCAPTCHA->new, "create ok";

my $mh_url = $captcha->mailhide_url( PUBKEY, PRIVKEY, 'someone@example.com' );
is $mh_url, 'http://mailhide.recaptcha.net/d?c=4jBBJ29mAjTuEk81neCXmYlMeLR6'
  . 'FAqNTe_fq72Tkq4%3d&k=UcV0oq5XNVM01AyYmMNRqvRA%3d%3d', 'url OK';

my $mh_html = $captcha->mailhide_html( PUBKEY, PRIVKEY, 'someone@example.com' );
is $mh_html,
  'some<a href="http://mailhide.recaptcha.net/d?c=4jBBJ29mAjTuEk'
  . '81neCXmYlMeLR6FAqNTe_fq72Tkq4%3d&amp;k=UcV0oq5XNVM01AyYmMNR'
  . 'qvRA%3d%3d" onclick="window.open(&apos;http://mailhide.reca'
  . 'ptcha.net/d?c=4jBBJ29mAjTuEk81neCXmYlMeLR6FAqNTe_fq72Tkq4%3'
  . 'd&amp;k=UcV0oq5XNVM01AyYmMNRqvRA%3d%3d&apos;, &apos;&apos;,'
  . ' &apos;height=300,location=0,menubar=0,resizable=0,scrollba'
  . 'rs=0,statusbar=0,toolbar=0,width=500&apos;); return false;"'
  . ' title="Reveal this e-mail address">...</a>@example.com', 'HTML OK';
