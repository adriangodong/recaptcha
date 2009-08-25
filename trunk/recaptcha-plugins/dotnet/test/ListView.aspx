<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ListView.aspx.cs" Inherits="RecaptchaTest.ListView" %>

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
        <asp:ListView ID="ListViewControl" InsertItemPosition="FirstItem" runat="server">
            <LayoutTemplate>
                <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
            </LayoutTemplate>
            <ItemTemplate>
                <div>
                    This is an item template for a list view.
                </div>
            </ItemTemplate>
            <InsertItemTemplate>
                <div>
                    <asp:TextBox ID="InputBox" runat="server" />
                    <asp:RequiredFieldValidator ID="InputBoxValidator" ControlToValidate="InputBox" ErrorMessage="This field is required." runat="server" />
                </div>
            </InsertItemTemplate>
            <EmptyDataTemplate>
                No data bound.
            </EmptyDataTemplate>
        </asp:ListView>
        <asp:Button ID="RecaptchaButton" Text="Submit" runat="server" OnClick="RecaptchaButton_Click" />
    </div>
    </form>
</body>
</html>
