package MT::Plugin::Recaptcha;

use MT;
use MT::Plugin;
use MT::JunkFilter qw(ABSTAIN);
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;

use vars qw($VERSION @ISA);
@ISA = qw(MT::Plugin);
$VERSION = 1.1;

my $plugin = new MT::Plugin::Recaptcha({
    name => 'Recaptcha',
    version => $VERSION,
    description => 'Uses Recaptcha system to reduce comment spam.',
    author_name => 'Josh Carter',
    author_link => 'http://multipart-mixed.com/',
    plugin_link => 'http://multipart-mixed.com/software/recaptcha.html',
    doc_link => 'http://multipart-mixed.com/software/recaptcha.html',
    settings => new MT::PluginSettings([
        ['public_key', { Default => 'YOUR_PUBLIC_KEY_HERE' }],
        ['private_key', { Default => 'YOUR_PRIVATE_KEY_HERE' }]
    ])
});
MT->add_plugin($plugin);

sub instance {
    $plugin
}

MT::Template::Context->add_tag('RecaptchaBox',
    sub {
        my $config = MT::Plugin::Recaptcha->instance->get_config_hash();
        
        return <<HTML
<script type="text/javascript">
var RecaptchaOptions = { theme : 'white' };
</script>
<script type="text/javascript"
   src="http://api.recaptcha.net/challenge?k=$config->{'public_key'}">
</script>

<noscript>
   <iframe src="http://api.recaptcha.net/noscript?k=$config->{'public_key'}" height="300" width="500" frameborder="0"></iframe><br>
   <textarea name="recaptcha_challenge_field" rows="3" cols="40"></textarea>
   <input type="hidden" name="recaptcha_response_field" value="manual_challenge">
</noscript>        
HTML
    }
);

MT->add_callback('CommentErrorFilter', 1, $plugin, sub {
    my ($eh, $app, $query) = @_;

    my $config = MT::Plugin::Recaptcha->instance->get_config_hash();
    my $challenge_field = $query->param('recaptcha_challenge_field');
    my $response_field = $query->param('recaptcha_response_field');
    
    unless ($challenge_field && length($challenge_field) > 0) {
        return "Failed CAPTCHA verification; please use your browser's " .
               "back button and re-enter the verification words. " .
               "Error: challenge field cannot be empty.";
    }

    unless ($response_field && length($response_field) > 0) {
        return "Failed CAPTCHA verification; please use your browser's " .
               "back button and re-enter the verification words. " .
               "Error: response field cannot be empty.";
    }

    my $ua = LWP::UserAgent->new();
    my $req = POST('http://api-verify.recaptcha.net/verify',
        ['privatekey' => $config->{'private_key'},
         'remoteip' => $query->remote_addr(),
         'challenge' => $challenge_field,
         'response' => $response_field]);
    my $response = $ua->request($req);
    
    if ($response->is_success()) {
        my @result = split(/\n/, $response->content());
        
        if ($result[0] eq 'true') {
            return undef;
        }
        else {
            return "Failed CAPTCHA verification; please use your browser's " .
                   "back button and re-enter the verification words. " .
                   "Error code: " . $result[1]
        }
    }
    else {
        return "Failed connecting to CAPCHTA verification service; please " .
               "try again later and/or contact me via email about this " .
               "error message: " . $response->status_line();
    }
});

1;
