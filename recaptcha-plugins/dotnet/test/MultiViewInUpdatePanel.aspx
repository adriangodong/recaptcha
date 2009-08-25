<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MultiViewInUpdatePanel.aspx.cs" Inherits="RecaptchaTest.MultiViewInUpdatePanel" %>

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
                <asp:MultiView ID="mv" ActiveViewIndex="0" runat="server">
                    <asp:View ID="vw1" runat="server">
                        <asp:Button ID="btnMove2" Text="Move to Step 2" runat="server" OnClick="btnMove2_Click" />
                    </asp:View>
                    <asp:View ID="vw2" runat="server">
                        <recaptcha:RecaptchaControl ID="RecaptchaControl" PublicKey="" PrivateKey="" runat="server" />
                        <br />
                        <asp:Button ID="btnMove3" Text="Move to Step 3" runat="server" OnClick="btnMove3_Click" />
                    </asp:View>
                    <asp:View ID="vw3" runat="server">
                        <asp:Label ID="result" runat="server" />
                    </asp:View>
                </asp:MultiView>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    </form>
</body>
</html>
