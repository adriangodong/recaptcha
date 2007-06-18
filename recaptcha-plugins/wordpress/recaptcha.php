<?php
/*
Plugin Name: reCAPTCHA
Plugin URI: http://recaptcha.net/plugins/wordpress
Description: Integrates a reCAPTCHA with wordpress
Version: 2.1
Author: Ben Maurer
Email: support@recaptcha.net
Author URI: http://bmaurer.blogspot.com
*/

require_once ('recaptchalib.php');
$recaptcha_opt = get_option('plugin_recaptcha');


function recaptcha_wp_get_html ($recaptcha_error) 
{
	global $recaptcha_opt;
	return recaptcha_get_html($recaptcha_opt['pubkey'], $recaptcha_error);
}

/**
 *  Embeds the reCAPTCHA widget into the comment form.
 * 
 */	
function recaptcha_comment_form() {
	//modify the comment form for the reCAPTCHA widget 
	$comment_string = <<<COMMENT_FORM
		<div id="recaptcha-submit-btn-area"></div> 
		<script type='text/javascript'>
		var sub = document.getElementById('submit');
		sub.parentNode.removeChild(sub);
		document.getElementById('recaptcha-submit-btn-area').appendChild (sub);
		document.getElementById('submit').tabIndex = 6;
		</script>
		<noscript>
		 <style type='text/css'>#submit {display:none;}</style>
		 <input name="submit" type="submit" id="submit-alt" tabindex="6" value="Submit Comment"/> 
		</noscript>
COMMENT_FORM;
	echo recaptcha_wp_get_html($_GET['rerror']) . $comment_string;
}


add_action( 'comment_form', 'recaptcha_comment_form' );


function recaptcha_wp_show_captcha_for_comment () {
        global $user_ID;
        return true;
}


/**
 * Checks if the reCAPTCHA guess was correct and sets an error session variable if not
 * @param array $comment_data
 * @return array $comment_data
 */
function recaptcha_wp_check_comment($comment_data) {

	global $user_ID, $recaptcha_opt;

	if (recaptcha_wp_show_captcha_for_comment ()) {
		if ( $comment_data['comment_type'] == '' ) { // Do not check trackbacks/pingbacks
			
			$challenge = $_POST['recaptcha_challenge_field'];
			$response = $_POST['recaptcha_response_field'];
		
			$recaptcha_response = recaptcha_check_answer ($recaptcha_opt ['privkey'], $_SERVER['REMOTE_ADDR'], $challenge, $response);
			if ($recaptcha_response->is_valid) {
				return $comment_data;
			}
			else {
				$comment_data['comment_content'] = $comment_data['comment_content'] . "reCAPTCHA WP Error:" . $recaptcha_response->error;
				$comment_data['comment_approved'] = false;
				return $comment_data;
			}
		}
	}
	return $comment_data;
}


/*
 * If the reCAPTCHA guess was incorrect from recaptcha_wp_check_comment, then redirect back to the comment form 
 * @param string $location
 * @param OBJECT $comment
 * @return string $location
 */
function recaptcha_wp_relative_redirect($location, $comment) {
	if(ereg("reCAPTCHA WP Error:", $comment->comment_content)) { 
		//replace the '#comment-' chars on the end of $location with '#commentform'.

		$location = substr($location, 0,strrpos($location, '#')) . '&rcommentid=' . $comment->comment_ID . 
			'&rerror=' . substr($comment->comment_content, (strrpos($comment->comment_content, 'reCAPTCHA WP Error:')) + 19) . '#commentform';

	}
	return $location;
}


/*
 * If the reCAPTCHA guess was incorrect from recaptcha_wp_check_comment, then insert their saved comment text
 * back in the comment form. 
 * @param boolean $approved
 * @return boolean $approved
 */
function recaptcha_wp_saved_comment() {
	if ( !is_single() && !is_page() )
		return;
	

	if ($_GET['rcommentid']) {
		$comment = get_comment($_GET['rcommentid']);

			echo "<script type='text/javascript'>
        			function addLoadEvent(func) {
                			var oldonload = window.onload;
			                if (typeof window.onload != 'function') {
                        			window.onload = func;
			                } else {
                        			window.onload = function() {
			                                oldonload();
        	        			        func();
                        			}
                			}
        			}

			        function insertSavedComment() {
		        	        var commentText = document.getElementById('comment');
					commentText.value = '" . addslashes(substr($comment->comment_content, 0, strpos($comment->comment_content, 'reCAPTCHA WP Error:'))) . "';
				}
        			addLoadEvent(insertSavedComment);
			     </script>";
		wp_delete_comment($comment->comment_ID);
	}

}


function recaptcha_wp_blog_domain ()
{
	$uri = parse_url(get_settings('siteurl'));
	return $uri['host'];
}

add_filter('wp_head', 'recaptcha_wp_saved_comment',0);
add_filter('preprocess_comment', 'recaptcha_wp_check_comment',0);
add_filter('comment_post_redirect', 'recaptcha_wp_relative_redirect',0,2);

function recaptcha_wp_add_options_to_admin() {
    if (function_exists('add_options_page')) {
		add_options_page('reCAPTCHA', 'reCAPTCHA', 8, plugin_basename(__FILE__), 'recaptcha_wp_options_subpanel');
    }
}

function recaptcha_wp_options_subpanel() {

	$optionarray_def = array(
				 'pubkey'	=> '',
				 'privkey' 	=> '',
				 );

	add_option('plugin_recaptcha', $optionarray_def, 'reCAPTCHA Options');

	/* Check form submission and update options if no error occurred */
	if (isset($_POST['submit']) ) {
		$optionarray_update = array (
			'pubkey'	=> $_POST['recaptcha_opt_pubkey'],
			'privkey'	=> $_POST['recaptcha_opt_privkey'],
		);
		update_option('plugin_recaptcha', $optionarray_update);
	}

	/* Get options */
	$optionarray_def = get_option('plugin_recaptcha');

	
?>

<!-- ############################## BEGIN: ADMIN OPTIONS ################### -->
<div class="wrap">


	<h2>reCAPTCHA Options</h2>
	<p>reCAPTCHA asks commenters to read two words from a book. One of these words proves
	   that they are a human, not a computer. The other word is a word that a computer couldn't read.
	   Because the user is known to be a human, the reading of that word is probably correct. So you don't
	   get comment spam, and the world gets books digitized. Everybody wins! For details, visit
	   the <a href="http://recaptcha.net/">reCAPTCHA website</a>.</p>

	<form name="form1" method="post" style="margin: auto; width: 25em;" action="<?php echo $_SERVER['PHP_SELF'] . '?page=' . plugin_basename(__FILE__); ?>&updated=true">


	<!-- ****************** Operands ****************** -->
	<fieldset class="options">
		<legend>reCAPTCHA Key</legend>
		<p>
			reCAPTCHA requires an API key, consisting of a "public" and a "private" key. You can sign up for a
			
			<a href="<?php echo recaptcha_get_signup_url (recaptcha_wp_blog_domain (), 'wordpress');?>" target="0">free reCAPTCHA key</a>.
		</p>
		<label style="font-weight:bold" for="recaptcha_opt_pubkey">Public Key:</label>
		<br />
		<input name="recaptcha_opt_pubkey" id="recaptcha_opt_pubkey" size="40" value="<?php  echo $optionarray_def['pubkey']; ?>" />
		<label style="font-weight:bold" for="recaptcha_opt_privkey">Private Key:</label>
		<br />
		<input name="recaptcha_opt_privkey" id="recaptcha_opt_privkey" size="40" value="<?php  echo $optionarray_def['privkey']; ?>" />

	</fieldset>


	<div class="submit">
		<input type="submit" name="submit" value="<?php _e('Update Options') ?> &raquo;" />
	</div>

	</form>

	<p style="text-align: center; font-size: .85em;">&copy; Copyright 2007&nbsp;&nbsp;<a href="http://recaptcha.net">reCAPTCHA</a></p>

</div> <!-- [wrap] -->
<!-- ############################## END: ADMIN OPTIONS ##################### -->


<?php


}


/* =============================================================================
   Apply the admin menu
============================================================================= */

add_action('admin_menu', 'recaptcha_wp_add_options_to_admin');


if ( !($recaptcha_opt ['pubkey'] && $recaptcha_opt['privkey'] ) && !isset($_POST['submit']) ) {
        function recaptcha_warning() {
        $path = plugin_basename(__FILE__);
                echo "
                <div id='recaptcha-warning' class='updated fade-ff0000'><p><strong>reCAPTCHA is not active</strong> You must <a href='options-general.php?page=" . $path . "'>enter your reCAPTCHA API key</a> for it to work</p></div>
                <style type='text/css'>
                #adminmenu { margin-bottom: 5em; }
                #recaptcha-warning { position: absolute; top: 7em; }
                </style>
                ";
        }
        add_action('admin_footer', 'recaptcha_warning');
        return;
}

?>
