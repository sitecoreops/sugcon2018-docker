FROM microsoft/windowsservercore:1709

ADD https://dist.nuget.org/win-x86-commandline/v4.1.0/nuget.exe C:\\Bin\\nuget.exe
ADD https://aka.ms/vs/15/release/vs_buildtools.exe C:\\TEMP\\vs_buildtools.exe

RUN setx /m PATH "%PATH%;C:\Bin" \
    && C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache --installPath C:\BuildTools --all \
    --remove Microsoft.VisualStudio.Workload.VCTools \
    --remove Microsoft.VisualStudio.Workload.NodeBuildTools \
    --remove Microsoft.VisualStudio.Workload.NetCoreBuildTools \
    || IF "%ERRORLEVEL%"=="3010" EXIT 0

RUN setx /m PATH "%PATH%;C:\BuildTools\MSBuild\15.0\bin"

ENTRYPOINT C:\BuildTools\Common7\Tools\VsDevCmd.bat &&

CMD ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]