"C:\Windows\Microsoft.NET\Framework64\v3.5\msbuild.exe" "..\library\Recaptcha-CLR2.csproj" /t:Rebuild /property:Configuration=Release
copy "..\library\bin\Release\*" ".\recaptcha\lib\.NetFramework 2.0"

"C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild.exe" "..\library\Recaptcha-CLR4.csproj" /t:Rebuild /property:Configuration=Release

copy "..\library\bin\Release\*" ".\recaptcha\lib\.NetFramework 4.0"

NuGet.exe pack ".\recaptcha\recaptcha.nuspec" /o ".\packages\"