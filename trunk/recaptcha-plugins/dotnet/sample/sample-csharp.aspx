<%@ Page Language="C#" %>
<%@ Register TagPrefix="recaptcha" Namespace="Recaptcha" Assembly="Recaptcha" %>
<script runat=server>
    void btnSubmit_Click(object sender, EventArgs args) {
        if (Page.IsValid) {
            lblResult.Text = "You Got It!";
            lblResult.ForeColor = System.Drawing.Color.Green;
        } else {
            lblResult.Text = "Incorrect";
            lblResult.ForeColor = System.Drawing.Color.Red;
        }
    }
</script>
<html>
<body>
    <form runat="server">
        <asp:Label Visible=false ID="lblResult" runat="server" />
    
        <recaptcha:RecaptchaControl
            ID="recaptcha"
            runat="server"
            Theme="red"
            PublicKey="6LcBAAAAAAAAAKtzVYRsIgOAAvCFge3iiMtf6hI9"            
            PrivateKey="6LcBAAAAAAAAACQnFb_BI5tX7OxqC-C5RtROzx-S"
            />
        <br />
        <asp:Button ID="btnSubmit" runat="server" Text="Submit" OnClick="btnSubmit_Click" />
    </form>
</body>
</html>
