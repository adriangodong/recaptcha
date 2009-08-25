<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateUserWizard.aspx.cs"
    Inherits="Recaptcha.Test.CreateUserWizard" %>

<%@ Register Assembly="Recaptcha" Namespace="Recaptcha" TagPrefix="recaptcha" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:CreateUserWizard ID="createUserWizard" runat="server">
            <WizardSteps>
                <asp:WizardStep ID="WizardStep1" runat="server" StepType="Step" Title="Recaptcha">
                    Are you a human?<br />
                    <recaptcha:RecaptchaControl ID="RecaptchaControl1" PublicKey="" PrivateKey="" runat="server" />
                </asp:WizardStep>
                <asp:CreateUserWizardStep ID="CreateUserWizardStep1" runat="server" />
                <asp:CompleteWizardStep ID="CompleteWizardStep1" runat="server" />
            </WizardSteps>
        </asp:CreateUserWizard>
    </div>
    </form>
</body>
</html>