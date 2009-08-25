using System;

namespace RecaptchaTest
{
    public partial class MultiView : System.Web.UI.Page
    {
        protected void btnMove2_Click(object sender, EventArgs e)
        {
            mv.SetActiveView(vw2);
        }

        protected void btnMove3_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                result.Text = "Success";
            }
            else
            {
                result.Text = RecaptchaControl.ErrorMessage;
            }

            mv.SetActiveView(vw3);
        }
    }
}
