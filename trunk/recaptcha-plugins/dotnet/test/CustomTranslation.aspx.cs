using System;
using System.Collections.Generic;

namespace RecaptchaTest
{
    public partial class CustomTranslation : System.Web.UI.Page
    {

        protected void Page_Init(object sender, EventArgs e)
        {

            var customTranslation = new Dictionary<string, string>();
            customTranslation.Add("instructions_visual", "Scrivi le due parole:");
            customTranslation.Add("instructions_audio", "Trascrivi ci\u00f2 che senti:");
            customTranslation.Add("play_again", "Riascolta la traccia audio");
            customTranslation.Add("cant_hear_this", "Scarica la traccia in formato MP3");
            customTranslation.Add("visual_challenge", "Modalit\u00e0 visiva");
            customTranslation.Add("audio_challenge", "Modalit\u00e0 auditiva");
            customTranslation.Add("refresh_btn", "Chiedi due nuove parole");
            customTranslation.Add("help_btn", "Aiuto");
            customTranslation.Add("incorrect_try_again", "Scorretto. Riprova.");

            RecaptchaControl.CustomTranslations = customTranslation;

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