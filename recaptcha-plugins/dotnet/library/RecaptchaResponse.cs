// Copyright (c) 2007 Adrian Godong, Ben Maurer
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

namespace Recaptcha
{
    /// <summary>
    /// Encapsulates a response from reCAPTCHA web service.
    /// </summary>
    public class RecaptchaResponse
    {
        public static readonly RecaptchaResponse Valid = new RecaptchaResponse(true, string.Empty);
        public static readonly RecaptchaResponse InvalidSolution = new RecaptchaResponse(false, "incorrect-captcha-sol");
        public static readonly RecaptchaResponse RecaptchaNotReachable = new RecaptchaResponse(false, "recaptcha-not-reachable");

        private bool isValid;
        private string errorCode;

        /// <summary>
        /// Initializes a new instance of the <see cref="RecaptchaResponse"/> class.
        /// </summary>
        /// <param name="isValid">Value indicates whether submitted reCAPTCHA is valid.</param>
        /// <param name="errorCode">Error code returned from reCAPTCHA web service.</param>
        internal RecaptchaResponse(bool isValid, string errorCode)
        {
            this.isValid = isValid;
            this.errorCode = errorCode;
        }

        public bool IsValid
        {
            get { return this.isValid; }
        }

        public string ErrorCode
        {
            get { return this.errorCode; }
        }

        public override bool Equals(object obj)
        {
            RecaptchaResponse other = (RecaptchaResponse)obj;
            if (other == null)
            {
                return false;
            }

            return other.IsValid == this.IsValid && other.ErrorCode == this.ErrorCode;
        }

        public override int GetHashCode()
        {
            return this.IsValid.GetHashCode() ^ this.ErrorCode.GetHashCode();
        }
    }
}