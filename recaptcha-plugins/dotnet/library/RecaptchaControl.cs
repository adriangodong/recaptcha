// Copyright (c) 2007 Adrian Godong, Ben Maurer
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


using System;
using System.ComponentModel;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web;

namespace Recaptcha
{
    [ToolboxData("<{0}:RecaptchaControl runat=\"server\" />")]
    [Designer(typeof(Recaptcha.Design.RecaptchaControlDesigner))]
    public class RecaptchaControl : WebControl, IValidator
    {
        #region Private Fields

        private const string RECAPTCHA_CHALLENGE_FIELD = "recaptcha_challenge_field";
        private const string RECAPTCHA_RESPONSE_FIELD = "recaptcha_response_field";

        private const string RECAPTCHA_SECURE_HOST = "https://api-secure.recaptcha.net";
        private const string RECAPTCHA_HOST = "http://api.recaptcha.net";

        private RecaptchaResponse recaptchaResponse;

        private string publicKey;
        private string privateKey;
        private string theme;
        private bool skipRecaptcha = false;
        private string errorMessage;

        #endregion

        #region Public Properties

        [Category("Settings")]
        [Description("The public key from admin.recaptcha.net. Can also be set using RecaptchaPublicKey in AppSettings.")]
        public String PublicKey
        {
            get { return publicKey; }
            set { publicKey = value; }
        }

        [Category("Settings")]
        [Description("The private key from admin.recaptcha.net. Can also be set using RecaptchaPrivateKey in AppSettings.")]
        public String PrivateKey
        {
            get { return privateKey; }
            set { privateKey = value; }
        }

        [Category("Appearence")]
        [DefaultValue("red")]
        [Description("The theme for the reCAPTCHA control. Currently supported values are red, blackglass, white, and clean")]
        public string Theme
        {
            get { return theme; }
            set { theme = value; }
        }

        [Category("Settings")]
        [DefaultValue(false)]
        [Description("Set this to true to stop reCAPTCHA validation. Useful for testing platform. Can also be set using RecaptchaSkipValidation in AppSettings")]
        public bool SkipRecaptcha
        {
            get { return skipRecaptcha; }
            set { skipRecaptcha = value; }
        }


        #endregion

        public RecaptchaControl()
        {
            publicKey = ConfigurationManager.AppSettings["RecaptchaPublicKey"];
            privateKey = ConfigurationManager.AppSettings["RecaptchaPrivateKey"];
            if (!bool.TryParse(ConfigurationManager.AppSettings["RecaptchaSkipValidation"], out skipRecaptcha))
            {
                skipRecaptcha = false;
            }

        }

        #region Overriden Methods

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (String.IsNullOrEmpty(PublicKey) || String.IsNullOrEmpty(PrivateKey)) {
                throw new ApplicationException("reCAPTCHA needs to be configured with a public & private key.");
            }
            Page.Validators.Add(this);
        }

        protected override void Render(HtmlTextWriter writer)
        {
            if (skipRecaptcha)
                writer.WriteLine("reCAPTCHA validation is skipped. Set SkipRecaptcha property to false to enable validation.");
            else RenderContents(writer);
        }

        protected override void RenderContents(HtmlTextWriter output)
        {
            // <script> setting
            output.AddAttribute(HtmlTextWriterAttribute.Type, "text/javascript");
            output.RenderBeginTag(HtmlTextWriterTag.Script);
            output.Indent++;
            output.WriteLine("var RecaptchaOptions = {");
            output.Indent++;
            output.WriteLine("theme : '{0}',", theme == null ? "" : theme);
            output.WriteLine("tabindex : {0}", TabIndex);
            output.Indent--;
            output.WriteLine("};");
            output.Indent--;
            output.RenderEndTag();

            // <script> display
            output.AddAttribute(HtmlTextWriterAttribute.Type, "text/javascript");
            output.AddAttribute(HtmlTextWriterAttribute.Src, GenerateChallengeUrl(false), false);
            output.RenderBeginTag(HtmlTextWriterTag.Script);
            output.RenderEndTag();
            
            output.RenderBeginTag(HtmlTextWriterTag.Noscript);
            output.Indent++;
            output.AddAttribute(HtmlTextWriterAttribute.Src, GenerateChallengeUrl(true), false);
            output.AddAttribute(HtmlTextWriterAttribute.Width, "500");
            output.AddAttribute(HtmlTextWriterAttribute.Height, "300");
            output.AddAttribute("frameborder", "0");
            output.RenderBeginTag(HtmlTextWriterTag.Iframe);
            output.RenderEndTag();
            output.RenderBeginTag(HtmlTextWriterTag.Br);
            output.RenderEndTag();
            output.AddAttribute(HtmlTextWriterAttribute.Name, "recaptcha_challenge_field");
            output.AddAttribute(HtmlTextWriterAttribute.Rows, "3");
            output.AddAttribute(HtmlTextWriterAttribute.Cols, "40");
            output.RenderBeginTag(HtmlTextWriterTag.Textarea);
            output.RenderEndTag();
            output.AddAttribute(HtmlTextWriterAttribute.Name, "recaptcha_response_field");
            output.AddAttribute(HtmlTextWriterAttribute.Value, "manual_challenge");
            output.AddAttribute(HtmlTextWriterAttribute.Type, "hidden");
            output.RenderBeginTag(HtmlTextWriterTag.Input);
            output.RenderEndTag();
            output.Indent--;
            output.RenderEndTag();
        }

        #endregion

        #region IValidator Members


        [LocalizableAttribute(true)]
        [DefaultValue("The verification words are incorrect.")]
        public string ErrorMessage
        {
            get {
                if (errorMessage != null)
                {
                    return errorMessage;
                }
                return "The verification words are incorrect.";
            }
            set
            {
                errorMessage = value;
            }
        }

        [Browsable(false)]
        public bool IsValid
        {
            get { return recaptchaResponse != null && recaptchaResponse.IsValid;  }
            set { }
        }

        public void Validate()
        {
            if (skipRecaptcha) {
                recaptchaResponse = RecaptchaResponse.Valid;
            } else {
                if (Visible && Enabled)
                {
                    RecaptchaValidator validator = new RecaptchaValidator();
                    validator.PrivateKey = PrivateKey;
                    validator.RemoteIP = Page.Request.UserHostAddress;
                    validator.Challenge = Context.Request.Form[RECAPTCHA_CHALLENGE_FIELD];
                    validator.Response = Context.Request.Form[RECAPTCHA_RESPONSE_FIELD];

                    recaptchaResponse = validator.Validate();
                }
            }
        }

        #endregion


        private string GenerateChallengeUrl(bool noScript)
        {
            StringBuilder urlBuilder = new StringBuilder();
            urlBuilder.Append(Context.Request.IsSecureConnection ? RECAPTCHA_SECURE_HOST : RECAPTCHA_HOST);
            urlBuilder.Append(noScript ? "/noscript?" : "/challenge?");
            urlBuilder.AppendFormat("k={0}", PublicKey);
            if (recaptchaResponse != null && recaptchaResponse.ErrorCode != "")
            {
                urlBuilder.AppendFormat("&error={0}", recaptchaResponse.ErrorCode);
            }
            return urlBuilder.ToString();
        }

    }

}