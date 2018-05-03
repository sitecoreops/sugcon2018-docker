# escape=`
FROM microsoft/mssql-server-windows-developer:1709

ENV ACCEPT_EULA=Y
ENV sa_password=HASH-epsom-sunset-cost7!
ENV DB_PREFIX='sc'
ENV INSTALL_PATH='c:/install/'
ENV DATA_PATH='c:/data/'

VOLUME ${DATA_PATH}

COPY Install-Databases.ps1 ${INSTALL_PATH}
COPY *.dacpac ${INSTALL_PATH}
COPY Boot.ps1 .

ADD https://dist.nuget.org/win-x86-commandline/v4.1.0/nuget.exe C:\\Windows\\nuget.exe
RUN New-Item -Path 'C:/tools' -ItemType Directory | Out-Null; `
    & nuget install Microsoft.Data.Tools.Msbuild -Version 10.0.61710.120 -OutputDirectory c:/tools

RUN & (Join-Path $env:INSTALL_PATH "Install-Databases.ps1") -InstallPath $env:INSTALL_PATH -DataPath $env:DATA_PATH -DatabasePrefix $env:DB_PREFIX; `
    Get-ChildItem -Path $env:INSTALL_PATH -Exclude "*.mdf", "*.ldf" | Remove-Item -Force;

CMD C:/Boot.ps1 -InstallPath $env:INSTALL_PATH -DataPath $env:DATA_PATH
