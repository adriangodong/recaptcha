<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomTranslation.aspx.cs" Inherits="RecaptchaTest.CustomTranslation" %>

<%@ Register Assembly="Recaptcha" Namespace="Recaptcha" TagPrefix="recaptcha" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <recaptcha:RecaptchaControl ID="RecaptchaControl" PublicKey="" PrivateKey="" runat="server" /><br />
        <asp:Label ID="RecaptchaResult" runat="server" /><br />
        <asp:Button ID="RecaptchaButton" Text="Submit" runat="server" onclick="RecaptchaButton_Click" />
    </div>
    </form>
</body>
</html>