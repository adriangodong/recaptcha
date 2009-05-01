<%@ Page Language="C#" %>
<%@ Register TagPrefix="recaptcha" Namespace="Recaptcha" Assembly="Recaptcha" %>
<script runat="server">
    void btnSubmit_Click(object sender, EventArgs args) {
        if (Page.IsValid) {
            lblResult.Text = "You Got It!";
            lblResult.ForeColor = System.Drawing.Color.Green;
        } else {
            lblResult.Text = "Incorrect, try again.";
            lblResult.ForeColor = System.Drawing.Color.Red;
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<body>
    <form runat="server">
    <div id="recaptcha_widget" style="display:none">
        <div id="recaptcha_image"></div>
        <span class="recaptcha_only_if_image">Enter the words above:</span>
        <span class="recaptcha_only_if_audio">Enter the numbers you hear:</span>
        <input type="text" id="recaptcha_response_field" name="recaptcha_response_field" />
        <asp:Button ID="btnSubmit" runat="server" Text="Submit" OnClick="btnSubmit_Click" />
        <div><asp:Label ID="lblResult" runat="server" /></div>
        <div><a href="javascript:Recaptcha.reload()">Get a new challange</a></div>
        <div class="recaptcha_only_if_image"><a href="javascript:Recaptcha.switch_type('audio')">Get an audio CAPTCHA</a></div>
        <div class="recaptcha_only_if_audio"><a href="javascript:Recaptcha.switch_type('image')">Get an image CAPTCHA</a></div>
        <%-- Note: the custom elements apear before the RecaptchaControl --%>
        <recaptcha:RecaptchaControl ID="recaptcha" runat="server" 
            Theme="custom" 
            CustomThemeWidget="recaptcha_widget"
            PublicKey="6LcBAAAAAAAAAKtzVYRsIgOAAvCFge3iiMtf6hI9"            
            PrivateKey="6LcBAAAAAAAAACQnFb_BI5tX7OxqC-C5RtROzx-S"
            />
        <div style="color: #C0C0C0; font-size: small;">Captcha provided by <a href="http://recaptcha.net/" style="color: #C0C0C0; text-decoration: none;">reCAPTCHA</a></div>
    </div>
    </form>
</body>
</html>
