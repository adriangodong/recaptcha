using System;

namespace Recaptcha.Test
{
    public partial class CreateUserWizardCustom : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            this.StatusMessage.Text = string.Empty;

            if (Page.IsPostBack)
            {
                Page.Validate();

                if (!Page.IsValid)
                {
                    this.StatusMessage.Text += "reCAPTCHA is not valid.<br />";
                }
            }
        }

        protected void createUserWizard_CreatingUser(object sender, System.Web.UI.WebControls.LoginCancelEventArgs e)
        {
            if (Page.IsValid)
            {
                this.StatusMessage.Text += "reCAPTCHA validated successfully.<br />";
            }
            else
            {
                // this section is not required, CreateUserWizard will not call this method if a validation error occurs.
            }
        }

        protected void createUserWizard_CreateUserError(object sender, System.Web.UI.WebControls.CreateUserErrorEventArgs e)
        {
            this.StatusMessage.Text += e.CreateUserError.ToString();
        }
    }
}