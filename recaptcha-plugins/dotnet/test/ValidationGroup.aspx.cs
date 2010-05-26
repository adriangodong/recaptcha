using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Recaptcha.Test
{
    public partial class ValidationGroup : System.Web.UI.Page
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