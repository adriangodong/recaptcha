// Copyright (c) 2007 Adrian Godong, Ben Maurer, Mike Hatalski, Derik Whittaker, Steven Carta
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
using System.Collections.Generic;
using System.Text;
using System.Web.Mvc;
using System.Configuration;
using System.Web.UI;
using System.IO;

namespace Recaptcha
{
    public static class RecaptchaControlMvc
    {
        private static string publicKey;
        private static string privateKey;
        private static bool skipRecaptcha;

        public static string PublicKey
        {
            get { return publicKey; }
            set { publicKey = value; }
        }

        public static string PrivateKey
        {
            get { return privateKey; }
            set { privateKey = value; }
        }

        public static bool SkipRecaptcha
        {
            get { return skipRecaptcha; }
            set { skipRecaptcha = value; }
        }

        static RecaptchaControlMvc()
        {
            publicKey = ConfigurationManager.AppSettings["RecaptchaPublicKey"];
            privateKey = ConfigurationManager.AppSettings["RecaptchaPrivateKey"];
            if (!bool.TryParse(ConfigurationManager.AppSettings["RecaptchaSkipValidation"], out skipRecaptcha))
            {
                skipRecaptcha = false;
            }
        }

        public class CaptchaValidatorAttribute : ActionFilterAttribute
        {
            private const string CHALLENGE_FIELD_KEY = "recaptcha_challenge_field";
            private const string RESPONSE_FIELD_KEY = "recaptcha_response_field";

            private RecaptchaResponse recaptchaResponse;

            public override void OnActionExecuting(ActionExecutingContext filterContext)
            {
                RecaptchaValidator validator = new Recaptcha.RecaptchaValidator();
                validator.PrivateKey = RecaptchaControlMvc.PrivateKey;
                validator.RemoteIP = filterContext.HttpContext.Request.UserHostAddress;
                validator.Challenge = filterContext.HttpContext.Request.Form[CHALLENGE_FIELD_KEY];
                validator.Response = filterContext.HttpContext.Request.Form[RESPONSE_FIELD_KEY];

                if (string.IsNullOrEmpty(validator.Challenge))
                {
                    this.recaptchaResponse = RecaptchaResponse.InvalidChallenge;
                }
                else if (string.IsNullOrEmpty(validator.Response))
                {
                    this.recaptchaResponse = RecaptchaResponse.InvalidResponse;
                }
                else
                {
                    this.recaptchaResponse = validator.Validate();
                }

                // this will push the result values into a parameter in our Action
                filterContext.ActionParameters["captchaValid"] = this.recaptchaResponse.IsValid;
                filterContext.ActionParameters["captchaErrorMessage"] = this.recaptchaResponse.ErrorMessage;

                base.OnActionExecuting(filterContext);
            }
        }

        public static string GenerateCaptcha(this HtmlHelper helper)
        {
            return GenerateCaptcha(helper, "recaptcha", "default", null);
        }

        public static string GenerateCaptcha(this HtmlHelper helper, string id, string theme, string language)
        {
            if (string.IsNullOrEmpty(publicKey) || string.IsNullOrEmpty(privateKey))
            {
                throw new ApplicationException("reCAPTCHA needs to be configured with a public & private key.");
            }

            var captchaControl = new Recaptcha.RecaptchaControl();
            captchaControl.ID = id;
            captchaControl.Theme = theme;
            if (!string.IsNullOrEmpty(language)) captchaControl.Language = language;
            captchaControl.PublicKey = publicKey;
            captchaControl.PrivateKey = privateKey;

            var htmlWriter = new HtmlTextWriter(new StringWriter());

            captchaControl.RenderControl(htmlWriter);

            return htmlWriter.InnerWriter.ToString();
        }
    }
}