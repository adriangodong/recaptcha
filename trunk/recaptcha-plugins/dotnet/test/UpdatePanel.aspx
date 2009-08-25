<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UpdatePanel.aspx.cs" Inherits="RecaptchaTest.UpdatePanel" %>

<%@ Register Assembly="Recaptcha" Namespace="Recaptcha" TagPrefix="recaptcha" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:ScriptManager ID="ScriptManager" runat="server" />
        <asp:UpdatePanel ID="UpdatePanelAsdf" runat="server">
            <ContentTemplate>
                <recaptcha:RecaptchaControl ID="RecaptchaControl" PublicKey="" PrivateKey="" runat="server" />
                <br />
                <asp:Label ID="RecaptchaResult" runat="server" /><br />
                <asp:Button ID="RecaptchaButton" Text="Submit" runat="server" OnClick="RecaptchaButton_Click" />
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    </form>
</body>
</html>