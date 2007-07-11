# This is a Movable Type plugin that handles reCAPTCHA authorization of 
# comment posts.
#
# Documentation and latest version:
#   http://multipart-mixed.com/software/recaptcha.html
# More info on reCAPTCHA:
#   http://recaptcha.net/
# Get a reCAPTCHA API Key:
#   http://recaptcha.net/api/getkey
# Discussion group:
#   http://groups.google.com/group/recaptcha
# 
# Copyright (c) 2007 Josh Carter
#
# AUTHORS:
#   Josh Carter
# CONTRIBUTIONS FROM:
#   Ian Peters
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

package MT::Plugin::Recaptcha;

use MT;
use MT::Plugin;
use MT::JunkFilter qw(ABSTAIN);
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;

use vars qw($VERSION @ISA);
@ISA = qw(MT::Plugin);
$VERSION = 1.2;

my $plugin = new MT::Plugin::Recaptcha({
    name => 'reCAPTCHA',
    version => $VERSION,
    description => 'Uses reCAPTCHA system to reduce comment spam.',
    author_name => 'Josh Carter',
    author_link => 'http://multipart-mixed.com/',
    plugin_link => 'http://multipart-mixed.com/software/recaptcha.html',
    doc_link => 'http://multipart-mixed.com/software/recaptcha.html',
    blog_config_template => \&config_tmpl,
    settings => new MT::PluginSettings([
        ['public_key', { Default => '' }],
        ['private_key', { Default => '' }],
        ['enabled', { Default => 0 }]
    ])
});
MT->add_plugin($plugin);

sub instance {
    $plugin
}

MT::Template::Context->add_tag('RecaptchaBox', sub {
    my $ctx = shift;
    my $blog_id = $ctx->stash('blog_id');
    my $config = MT::Plugin::Recaptcha->instance->get_config_hash("blog:$blog_id");

    unless ($config->{'enabled'}) {
        return '';
    }

    return <<HTML
<script type="text/javascript">
var RecaptchaOptions = { theme : 'white' };
</script>
<script type="text/javascript" src="http://api.recaptcha.net/challenge?k=$config->{'public_key'}">
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
    my ($eh, $app, $entry) = @_;
    my $query = $app->{query};
    my $blog_id = $entry->blog_id;
    my $config = MT::Plugin::Recaptcha->instance->get_config_hash("blog:$blog_id");

    unless ($config->{'enabled'}) {
        return undef;
    }

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
         'remoteip' => $app->remote_ip,
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

sub config_tmpl {
    my $tmpl = <<'EOT';
<p>reCAPTCHA is a CAPTCHA implementation that protects your blog from spam, while helping digitize old texts.  For more information about reCAPTCHA, and to sign up for your own keys, please visit <a href="http://recaptcha.net/">recaptcha.net</a>.</p>
<div class="setting">
    <label for="enabled"><input type="checkbox" name="enabled" id="enabled" value="1"<TMPL_IF NAME=ENABLED_1> checked="checked" </TMPL_IF>/> Enable reCAPTCHA filtering for this blog</label>
</div>
<div class="setting">
    <div class="label"><label for="public_key"><MT_TRANS phrase="Public Key:"></label></div>
    <div class="field">
    <input name="public_key" id="public_key" size="40" value="<TMPL_VAR NAME=PUBLIC_KEY ESCAPE=HTML>" />
    </div>
</div>
<div class="setting">
    <div class="label"><label for="private_key"><MT_TRANS phrase="Private Key:"></label></div>
    <div class="field">
    <input name="private_key" id="private_key" size="40" value="<TMPL_VAR NAME=PRIVATE_KEY ESCAPE=HTML>" />
    </div>
</div>
EOT
}

1;
