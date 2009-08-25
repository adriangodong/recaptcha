<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ValidationSummary.aspx.cs" Inherits="RecaptchaTest.ValidationSummary" %>

<%@ Register Assembly="Recaptcha" Namespace="Recaptcha" TagPrefix="recaptcha" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:ValidationSummary ID="ValidationSummaryAsdf" runat="server" />
        <recaptcha:RecaptchaControl ID="RecaptchaControl" PublicKey="" PrivateKey="" runat="server" /><br />
        <recaptcha:RecaptchaControl ID="RecaptchaControl2" PublicKey="" PrivateKey="" Visible="false" runat="server" /><br />
        <asp:Button ID="RecaptchaButton" Text="Submit" runat="server" OnClick="RecaptchaButton_Click" />
    </div>
    </form>
</body>
</html>