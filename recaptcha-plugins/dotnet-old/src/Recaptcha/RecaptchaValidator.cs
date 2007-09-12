//Copyright (c) 2007 Joseph Hill

//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.ComponentModel;
using System.IO;
using System.Net;
using System.Text;

namespace Recaptcha
{
	/// <summary>
	/// RecaptchaValidator uses the reCAPTCHA web services to validate that
	/// a page is being access by a real human.
	/// </summary>
	[ToolboxData("<{0}:RecaptchaValidator runat=\"server\" ErrorMessage=\"RecaptchaValidator\"></{0}:RecaptchaValidator>")]
	public class RecaptchaValidator : BaseValidator
	{
		#region Public Enums 
		/// <summary>
		/// Defines which theme to use for reCAPTCHA
		/// </summary>
		public enum RecaptchaTheme {
			Default,
			BlackGlass,
			Red,
			White
		}
		#endregion

		#region Public Constructors
		/// <summary>
		/// Default .ctor
		/// </summary>
		public RecaptchaValidator() {
			//
			//
		}
		#endregion

		#region Public Properties
		/// <summary>
		/// Used when communicating between your server and the reCAPTCHA server. 
		/// (Be sure to keep it a secret.)
		/// </summary>
		[Category("Behavior")]
		public String PrivateKey {
			get {
				return _privateKey;
			}
			set {
				_privateKey = value;
			}
		}

		/// <summary>
		/// Used in the JavaScript code emitted to client.
		/// </summary>
		[Category("Behavior")]
		public String PublicKey {
			get {
				return _publicKey;
			}
			set {
				_publicKey = value;
			}
		}

		/// <summary>
		/// Defines which theme to use for reCAPTCHA
		/// </summary>
		[DefaultValue("Default"), Category("Appearance")]
		public RecaptchaTheme Theme {
			get {
				if (this.ViewState[ViewStateKey.RecaptchaTheme.ToString()] is RecaptchaTheme)
					return (RecaptchaTheme)this.ViewState[ViewStateKey.RecaptchaTheme.ToString()];
				return RecaptchaTheme.Default;
			}
			set
            {
				this.ViewState[ViewStateKey.RecaptchaTheme.ToString()] = value;
            }
		}
		#endregion

		#region Public Methods

		/// <summary>
		///   Writes the opening tag of the markup element associated with the 
		///   specified Syste.Web.UI.HtmlTextWriterTag enumeration value 
		///   to the output stream.
		/// </summary>
		/// 
		/// <param name="writer">
		///   HtmlTextWriter for control begin tag output.
		/// </param>
		///
		public override void RenderBeginTag(HtmlTextWriter writer) {

			String options = this.GetRecaptchaOptions();

			if (null != options && options.Length > 0) {
				writer.WriteLine(
					"<script>var RecaptchaOptions = {{ {0} }};</script>",
					options);				
			}

			String err = String.Empty;
			if (null != this.LastError && 
				this.LastError.Length > 0 &&
				this.LastError != "success") {
				err = String.Format("&error={0}", this.LastError);
			}

			writer.WriteLine(
@"<script type=""text/javascript""
   src=""{0}/challenge?k={1}{2}"">
</script>

<noscript>
   <iframe src=""{0}/noscript?k={1}{2}""
       height=""300"" width=""500"" frameborder=""0""></iframe><br>
   <textarea name=""recaptcha_challenge_field"" rows=""3"" cols=""40"">
   </textarea>
   <input type=""hidden"" name=""recaptcha_response_field"" 
       value=""manual_challenge"">
</noscript>",
				  this.GetRecatpchaServer(),
				  this.PublicKey,
				  err);

			base.RenderBeginTag(writer);
		}
		#endregion

		#region Protected Enums
		/// <summary>
		/// Keys to index internal ViewState values
		/// </summary>
		protected enum ViewStateKey {
			RecaptchaTheme
		}
		#endregion
		
		#region Protected Methods
		/// <summary>
		/// Called to verify that a WebControl has been selected to validate
		/// </summary>
		/// <returns>true if ControlToValidate is WebControl</returns>
		protected override bool ControlPropertiesValid() {
			Control c = NamingContainer.FindControl(ControlToValidate);
			return c is WebControl;
		}

		/// <summary>
		/// Calls the reCAPTCHA web service to validate the user's response.
		/// </summary>
		/// <returns>true if user passes reCAPTCHA test</returns>
		protected override bool EvaluateIsValid() {
			return this.ValidateUserResponse();
		}
		#endregion

		#region Protected Properties
		/// <summary>
		/// The last error returned from the reCAPTCHA Verify Server
		/// </summary>
		protected String LastError {
			get {
				return _lastError;
			}
			set {
				_lastError = value;
			}
		}

		/// <summary>
		/// The last result (true or false)
		/// returned from the reCAPTCHA Verify Server
		/// </summary>
		protected String LastResult {
			get {
				return _lastResponse;
			}
			set {
				_lastResponse = value;
			}
		}
		#endregion

		#region Private Methods
		/// <summary>
		/// Checks result returned by verify server.
		/// Calls verify server if it has not yet been called for this round trip.
		/// </summary>
		/// <returns>true if verify server returns true</returns>
		public bool ValidateUserResponse() {
			if (null == this.LastError || this.LastError.Length == 0) {
				this.ValidateAgainstRecaptchaServer();
			}
			return "true" == this.LastResult;
		}

		/// <summary>
		/// Validates user's response against verify server.
		/// Caches result in LastResponse and LastError for 
		/// additional validation requests.
		/// </summary>
		private void ValidateAgainstRecaptchaServer() {
			this.LastResult = String.Empty;
			this.LastError = String.Empty;
			try {
				HttpWebRequest request = WebRequest.Create(VERIFY_URL) as HttpWebRequest;
				request.Method = "POST";
				request.ContentType = "application/x-www-form-urlencoded";

				String postData = this.GetVerifyPostData();

				byte[] bytes = Encoding.UTF8.GetBytes(postData);
				request.ContentLength = bytes.Length;
				request.ProtocolVersion = new Version("1.0");

				using (Stream requestStream = request.GetRequestStream()) {
					requestStream.Write(bytes, 0, bytes.Length);
					requestStream.Close();
				}

				using (HttpWebResponse response = request.GetResponse() as HttpWebResponse)
				using (Stream responseStream = response.GetResponseStream())
				using (StreamReader reader = new StreamReader(responseStream, Encoding.UTF8)) {
					String result = reader.ReadToEnd();
					String[] lines = result.Split();
					if (lines.Length > 0) 
						this.LastResult = lines[0];

					if (lines.Length > 1)
						this.LastError = lines[1];
				}
			}
			catch {
				//TODO: Something probably needs to be done here to 
				//  log this exception and provide more specific error messages.
				this.LastResult = "false";
				this.LastError = "recaptcha-not-reachable";
			}
		}

		/// <summary>
		/// 
		/// </summary>
		/// <returns></returns>
		private String GetRecatpchaServer() {
			return this.Page.Request.Url.AbsoluteUri.ToLower().StartsWith("https") ?
				CHALLENGE_SERVER_SECURE : CHALLENGE_SERVER;
		}

		/// <summary>
		/// 
		/// </summary>
		/// <returns></returns>
		private String GetVerifyPostData() {

			String remoteIp = this.Page.Request.UserHostAddress == "::1" ?
				"127.0.0.1" : this.Page.Request.UserHostAddress;

			return String.Format(
				"privatekey={0}&remoteip={1}&challenge={2}&response={3}",
				this.PrivateKey,
				remoteIp,
				this.Page.Request.Form[RECAPTCHA_CHALLENGE_FIELD],
				this.Page.Request.Form[RECAPTCHA_RESPONSE_FIELD]);
		}

		/// <summary>
		/// Gets reCAPTCHA options formatted for javascript initialization
		/// </summary>
		/// <returns>String</returns>
		private String GetRecaptchaOptions() {
			String theme = String.Empty;
			switch (this.Theme) {
				case RecaptchaTheme.BlackGlass:
					theme = "theme : 'blackglass'";
					break;
				case RecaptchaTheme.White:
					theme = "theme : 'white'";
					break;
				case RecaptchaTheme.Red:
					theme = "theme : 'red'";
					break;
				case RecaptchaTheme.Default:
				default:
					break;
			}

			return String.Format(
				"{0}{1}tabindex: {2}",
				theme,
				theme == String.Empty ? "" : ", ",
				this.TabIndex);
		}
		#endregion

		#region Private Fields
		/// <summary>
		/// Field to store private key value.  
		/// This MUST be kept secret (i.e., this shouldn't be in the ViewState.)
		/// </summary>
		private String _privateKey;

		/// <summary>
		/// Field to store public key value.
		/// </summary>
		private String _publicKey;

		/// <summary>
		/// The last error returned from the reCAPTCHA Verify Server
		/// </summary>
		private String _lastError;
		

		/// <summary>
		/// The last response returned from the reCAPTCHA Verify Server
		/// </summary>
		private String _lastResponse;
		#endregion

		#region Private Constants
		/// <summary>
		/// Client side API. 
		/// The plain api.recaptcha.net (non-SSL has higher performance)
		/// </summary>
		private const string CHALLENGE_SERVER = "http://api.recaptcha.net";

		/// <summary>
		/// Secure client side API. 
		/// If your site is served over SSL, 
		/// use the api-secure version to prevent browser warnings. 
		/// </summary>
		private const string CHALLENGE_SERVER_SECURE = "https://api-secure.recaptcha.net";

		/// <summary>
		/// Verification server: your application server interacts with this. 
		/// </summary>
		private const string VERIFY_URL = "http://api-verify.recaptcha.net/verify";

		/// <summary>
		/// The recaptcha_challenge_field form variable
		/// </summary>
		private const string RECAPTCHA_CHALLENGE_FIELD = "recaptcha_challenge_field";

		/// <summary>
		/// The recaptcha_response_field form variable
		/// </summary>
		private const string RECAPTCHA_RESPONSE_FIELD = "recaptcha_response_field";

		#endregion		
	}
}
