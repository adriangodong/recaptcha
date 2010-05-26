<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ValidationGroup.aspx.cs" Inherits="Recaptcha.Test.ValidationGroup" %>

<%@ Register Assembly="Recaptcha" Namespace="Recaptcha" TagPrefix="recaptcha" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <recaptcha:RecaptchaControl ID="RecaptchaControl" PublicKey="" PrivateKey="" runat="server" /><br />
        <asp:Label ID="RecaptchaResult" runat="server" /><br />
    </div>
    <div>
        This textbox must not be empty (Validation Group = empty):<br />
        <asp:TextBox ID="GroupATextBox" runat="server" /><br />
        <asp:RequiredFieldValidator
            ID="GroupATextBoxValidator"
            ControlToValidate="GroupATextBox" 
            ErrorMessage="Value required."
            Display="Dynamic"
            ValidationGroup=""
            EnableClientScript="false"
            runat="server" />
    </div>
    <div>
        This textbox must not be empty (Validation Group = "GroupB"):<br />
        <asp:TextBox ID="GroupBTextBox" runat="server" /><br />
        <asp:RequiredFieldValidator
            ID="GroupBTextBoxTextBoxValidator"
            ControlToValidate="GroupBTextBox" 
            ErrorMessage="Value required."
            Display="Dynamic"
            ValidationGroup="GroupB"
            EnableClientScript="false"
            runat="server" />
    </div>
    <div>
        <asp:Button ID="RecaptchaButton" Text="Submit (and Validate empty)" runat="server" onclick="RecaptchaButton_Click" />
        <asp:Button ID="GroupBButton" Text="Submit (and Validate only GroupB)" ValidationGroup="GroupB" runat="server" onclick="RecaptchaButton_Click" />
    </div>
    </form>
</body>
</html>
