using System;
using System.Collections.Generic;

namespace RecaptchaTest
{
    public partial class ListView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var list = new List<string> { string.Empty, string.Empty };
            ListViewControl.DataSource = list;
            ListViewControl.DataBind();
        }

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