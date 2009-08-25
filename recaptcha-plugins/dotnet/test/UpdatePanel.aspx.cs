using System;

namespace RecaptchaTest
{
    public partial class UpdatePanel : System.Web.UI.Page
    {
        protected void RecaptchaButton_Click(object sender, EventArgs e)
        {
            if (this.Page.IsValid)
            {
                this.RecaptchaResult.Text = "Success";
            }
            else
            {
                this.RecaptchaResult.Text = this.RecaptchaControl.ErrorMessage;
            }
        }
    }
}
