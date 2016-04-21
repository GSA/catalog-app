FROM tomcat:jre8

COPY fgdc2iso.war /usr/local/tomcat/webapps/
COPY saxon-license.lic /etc
COPY tl_2009_us_uac00_url.shp.xml /tmp 
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
