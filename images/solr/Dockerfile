# escape=`
FROM registry.valtech.dk/sitecore:9.0.171219-solr as builder
FROM openjdk:8-windowsservercore-1709 as final

COPY --from=builder /solr /solr
COPY --from=builder /clean /clean
COPY --from=builder /Boot.ps1 /

VOLUME c:/data

# Workaround for java issues with Windows container symlinks: https://github.com/moby/moby/issues/27537#issuecomment-271546031
RUN REG ADD 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices' /v 'G:' /d '\??\C:\data' /reg:64

# Set solr home dir to above mapped drive
ENV SOLR_HOME=g:/

# Expose default port
EXPOSE 8983

CMD C:/Boot.ps1 -SolrPath 'c:/solr' -SolrPort 8983 -InstallPath 'c:/clean' -DataPath 'c:/data'
