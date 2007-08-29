// MIT License:

//Copyright (c) 2007 Adrian Godong

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
using System.ComponentModel;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Recaptcha2
{
  [ToolboxData("<{0}:RecaptchaControl Theme=red runat=server />")]
  public class RecaptchaControl : WebControl, IValidator
  {
    #region Private Fields

    private const string RECAPTCHA_CHALLENGE_FIELD = "recaptcha_challenge_field";
    private const string RECAPTCHA_RESPONSE_FIELD = "recaptcha_response_field";

    private String standardApiBaseUrl;
    private String secureApiBaseUrl;
    private String verifyApiUrl;
    private String publicKey;
    private String privateKey;
    private Boolean isSecure;
    private String error = "";
    private RecaptchaTheme theme;
    private Boolean useExpect100Continue;
    private Boolean skipRecaptcha = false;

    #endregion

    #region Public Properties

    [Category("Settings")]
    public String PublicKey
    {
      get { return publicKey; }
      set { publicKey = value; }
    }

    [Category("Settings")]
    public String PrivateKey
    {
      get { return privateKey; }
      set { privateKey = value; }
    }

    [Category("Settings")]
    [DefaultValue(false)]
    public Boolean IsSecure
    {
      get { return isSecure; }
      set { isSecure = value; }
    }

    [Category("Settings")]
    [DefaultValue(RecaptchaTheme.red)]
    public RecaptchaTheme Theme
    {
      get { return theme; }
      set { theme = value; }
    }

    [Category("Settings")]
    [DefaultValue(0)]
    public override Int16 TabIndex
    {
      get { return base.TabIndex; }
      set { base.TabIndex = value; }
    }

    [Category("Settings")]
    [DefaultValue(true)]
    [Description("Set this to false if having 417 errors.")]
    public Boolean UseExpect100Continue
    {
      get { return useExpect100Continue; }
      set { useExpect100Continue = value; }
    }

    [Category("Settings")]
    [DefaultValue(false)]
    [Description("Set this to true to stop reCAPTCHA validation. Useful for testing platform.")]
    public Boolean SkipRecaptcha
    {
      get { return skipRecaptcha; }
      set { skipRecaptcha = value; }
    }

    [Category("Settings")]
    [DefaultValue("http://api.recaptcha.net")]
    public string StandardApiBaseUrl
    {
      get { return standardApiBaseUrl; }
      set
      {
        standardApiBaseUrl = standardApiBaseUrl.TrimEnd('/');
        standardApiBaseUrl = value;
      }
    }

    [Category("Settings")]
    [DefaultValue("https://api-secure.recaptcha.net")]
    public string SecureApiBaseUrl
    {
      get { return secureApiBaseUrl; }
      set
      {
        secureApiBaseUrl = secureApiBaseUrl.TrimEnd('/');
        secureApiBaseUrl = value;
      }
    }

    [Category("Settings")]
    [DefaultValue("http://api-verify.recaptcha.net/verify")]
    public string VerifyApiUrl
    {
      get { return verifyApiUrl; }
      set { verifyApiUrl = value; }
    }

    #endregion

    public RecaptchaControl()
    {
      publicKey = ConfigurationManager.AppSettings["RecaptchaPublicKey"];
      privateKey = ConfigurationManager.AppSettings["RecaptchaPrivateKey"];
    }

    #region Overriden Methods

    protected override void OnInit(EventArgs e)
    {
      base.OnInit(e);
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
      //if (HttpContext.Current.Request.Browser.EcmaScriptVersion.Major > 1)
      //{
      // <script> setting
      output.RenderBeginTag(HtmlTextWriterTag.Script);
      output.Indent++;
      output.WriteLine("var RecaptchaOptions = {");
      output.Indent++;
      output.WriteLine("theme : '{0}',", theme.ToString());
      output.WriteLine("tabindex : {0}", base.TabIndex);
      output.Indent--;
      output.WriteLine("};");
      output.Indent--;
      output.RenderEndTag();

      // <script> display
      output.AddAttribute(HtmlTextWriterAttribute.Type, "text/javascript");
      output.AddAttribute(HtmlTextWriterAttribute.Src, GenerateChallengeUrl(false), false);
      output.RenderBeginTag(HtmlTextWriterTag.Script);
      output.RenderEndTag();
      //}
      //else
      //{
      // <noscript> display
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
      //}
    }

    #endregion

    #region IValidator Members

    public string ErrorMessage
    {
      get { return error; }
      set { }
    }

    public bool IsValid
    {
      get { return (error == String.Empty); }
      set { }
    }

    public void Validate()
    {
      if (!skipRecaptcha) DoValidation();
    }

    #endregion

    #region Private Methods

    private void DoValidation()
    {
      HttpWebRequest request = (HttpWebRequest)WebRequest.Create(GenerateVerifyUrl());
      request.ProtocolVersion = HttpVersion.Version10;
      request.Method = "POST";

      request.ContentType = "application/x-www-form-urlencoded";

      String postData = String.Format("privatekey={0}&remoteip={1}&challenge={2}&response={3}",
                                      PrivateKey,
                                      Page.Request.UserHostAddress,
                                      Context.Request.Form[RECAPTCHA_CHALLENGE_FIELD],
                                      Context.Request.Form[RECAPTCHA_RESPONSE_FIELD]);
      byte[] postBytes = Encoding.UTF8.GetBytes(postData);

      using (Stream requestStream = request.GetRequestStream())
        requestStream.Write(postBytes, 0, postBytes.Length);

      WebResponse httpResponse = null;
      string[] results;
      try
      {
        httpResponse = request.GetResponse();
        using (Stream receiveStream = httpResponse.GetResponseStream())
        {
          using (StreamReader readStream = new StreamReader(receiveStream, Encoding.UTF8))
          {
            results = readStream.ReadToEnd().Split();
          }
        }
      }
      catch (WebException ex) //timeout
      {
        results = new string[] { "false", "recaptcha-not-reachable" };
        EventLog.WriteEntry("Application", ex.Message, EventLogEntryType.Error);
      }
      finally
      {
        if (httpResponse != null) httpResponse.Close();
      }

      switch (results[0])
      {
        case "true":
          error = String.Empty;
          break;
        case "false":
          error = results[1];
          break;
        default:
          throw new InvalidProgramException("Unknown status response.");
      }

      ServicePointManager.Expect100Continue = true;
    }

    private string GenerateChallengeUrl(Boolean noScript)
    {
      StringBuilder urlBuilder = new StringBuilder();
      urlBuilder.Append(isSecure ? SecureApiBaseUrl : StandardApiBaseUrl);
      urlBuilder.Append(noScript ? "/noscript?" : "/challenge?");
      urlBuilder.AppendFormat("k={0}&error={1}", publicKey, error);
      return urlBuilder.ToString();
    }

    private string GenerateVerifyUrl()
    {
      StringBuilder urlBuilder = new StringBuilder();
      urlBuilder.Append(VerifyApiUrl);
      return urlBuilder.ToString();
    }

    #endregion
  }

  public enum RecaptchaTheme : byte
  {
    red,
    white,
    blackglass
  }
}