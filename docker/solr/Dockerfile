FROM ubuntu:14.04
RUN apt-get -q -y update && apt-get -q -y install openjdk-7-jdk
RUN mkdir /usr/java && \
        ln -s /usr/lib/jvm/java-7-openjdk-amd64 /usr/java/default && \
        apt-get -y install solr-tomcat

COPY schema.xml /etc/solr/conf/schema.xml

ENV CATALINA_BASE=/var/lib/tomcat6

EXPOSE 8080

CMD ["/usr/bin/java", "-Djava.util.logging.config.file=/var/lib/tomcat6/conf/logging.properties", "-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager", "-Djava.endorsed.dirs=/usr/share/tomcat6/endorsed", "-classpath", "/usr/share/tomcat6/bin/bootstrap.jar", "-Dcatalina.base=/var/lib/tomcat6", "-Dcatalina.home=/usr/share/tomcat6", "-Djava.io.tmpdir=/var/lib/tomcat6/temp", "org.apache.catalina.startup.Bootstrap", "start"]
