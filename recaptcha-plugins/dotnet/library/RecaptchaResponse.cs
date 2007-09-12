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

using System;
using System.Text;

namespace Recaptcha
{
    public class RecaptchaResponse
    {
        public static RecaptchaResponse Valid = new RecaptchaResponse(true, "");
        public static RecaptchaResponse InvalidSolution = new RecaptchaResponse(false, "incorrect-captcha-sol");
        public static RecaptchaResponse RecaptchaNotReachable = new RecaptchaResponse(false, "recaptcha-not-reachable");

        bool isValid;
        string errorCode;

        internal RecaptchaResponse(bool isValid, string errorCode)
        {
            this.isValid = isValid;
            this.errorCode = errorCode;
        }

        public bool IsValid
        {
            get { return isValid; }
        }

        public string ErrorCode
        {
            get { return errorCode; }
        }

        public override bool Equals(object obj)
        {
            RecaptchaResponse other = (RecaptchaResponse)obj;
            if (other == null)
            {
                return false;
            }

            return other.IsValid == IsValid && other.ErrorCode == ErrorCode;
        }

        public override int GetHashCode()
        {
            return IsValid.GetHashCode() ^ ErrorCode.GetHashCode();
        }
    }
}
