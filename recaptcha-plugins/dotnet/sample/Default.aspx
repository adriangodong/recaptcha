<%@ Page language="c#" AutoEventWireup="false" %>

<%@ Register 
        Assembly="Recaptcha"
        Namespace="Recaptcha" 
        TagPrefix="recatpcha" %>
        
<script runat="server">
	private void Button1_Click(object sender, System.EventArgs e) {
		Page.Validate();
		if (Page.IsValid) {
			this.Label1.Text="Congrats!  You Passed!";
			this.RecaptchaValidator1.Visible = false;
		}
	}
</script>        
        
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title>reCAPTCHA</title>
	</HEAD>
	<body>
		<form id="Form1" method="post" runat="server">
			<asp:label runat="server" ID="Label1"></asp:label><br>
			<recatpcha:RecaptchaValidator ID="RecaptchaValidator1" runat="server" PublicKey="xxxxxxxxxxxxxxxxxxxxxx"
				PrivateKey="xxxxxxxxxxxxxxx" Theme="BlackGlass" ControlToValidate="TextBox1"></recatpcha:RecaptchaValidator><BR>
			<br>
			<asp:TextBox ID="TextBox1" TextMode="MultiLine" runat="server"></asp:TextBox><br>
			<asp:Button ID="Button1" runat="server" Text="Button" CausesValidation="true" OnClick="Button1_Click" /><br>
			<a href="Default.aspx">Start Over</a>
		</form>
	</body>
</HTML>
