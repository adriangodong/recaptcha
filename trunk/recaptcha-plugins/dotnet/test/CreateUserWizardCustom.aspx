<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateUserWizardCustom.aspx.cs"
    Inherits="Recaptcha.Test.CreateUserWizardCustom" %>

<%@ Register Assembly="Recaptcha" Namespace="Recaptcha" TagPrefix="recaptcha" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:CreateUserWizard ID="createUserWizard" runat="server" 
            oncreateusererror="createUserWizard_CreateUserError" 
            oncreatinguser="createUserWizard_CreatingUser">
            <WizardSteps>
                <asp:CreateUserWizardStep ID="CreateUserWizardStep1" runat="server">
                    <ContentTemplate>
                        Custom CreateUserWizardStep<br />
                        Are you a human?<br />
                        <recaptcha:RecaptchaControl ID="RecaptchaControl1" PublicKey="" PrivateKey="" runat="server" />
                        <asp:TextBox ID="UserName" Text="Username" runat="server" />
                        <asp:TextBox ID="Password" Text="P@ssw0rd" runat="server" />
                        <asp:TextBox ID="Email" Text="Email" runat="server" />
                        <asp:TextBox ID="Question" Text="Question" runat="server" />
                        <asp:TextBox ID="Answer" Text="Answer" runat="server" />
                    </ContentTemplate>
                </asp:CreateUserWizardStep>
                <asp:CompleteWizardStep ID="CompleteWizardStep1" runat="server" />
            </WizardSteps>
        </asp:CreateUserWizard>
        <asp:Literal ID="StatusMessage" runat="server" />
    </div>
    </form>
</body>
</html>
