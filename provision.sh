#!/bin/bash

# Install required libraries not in cookbooks
echo "Installing Solr..."
cd /opt && wget --quiet http://archive.apache.org/dist/lucene/solr/4.8.1/solr-4.8.1.tgz
tar -xf solr-4.8.1.tgz && cp -R solr-4.8.1/example /opt/solr

echo 'NO_START=0 # Start on boot
JAVA_OPTIONS="-Dsolr.solr.home=/opt/solr/solr $JAVA_OPTIONS"
JAVA_HOME=/usr/java/default
JETTY_HOME=/opt/solr
JETTY_USER=solr
JETTY_LOGS=/opt/solr/logs
JETTY_HOST=127.0.0.1
JETTY_PORT=8983' >> /etc/default/jetty

echo '<?xml version="1.0"?>
  <!DOCTYPE Configure PUBLIC "-//Mort Bay Consulting//DTD Configure//EN" "http://jetty.mortbay.org/configure.dtd">
  <!-- =============================================================== -->
  <!-- Configure stderr and stdout to a Jetty rollover log file -->
  <!-- this configuration file should be used in combination with -->
  <!-- other configuration files.  e.g. -->
  <!--    java -jar start.jar etc/jetty-logging.xml etc/jetty.xml -->
  <!-- =============================================================== -->
  <Configure id="Server" class="org.mortbay.jetty.Server">

      <New id="ServerLog" class="java.io.PrintStream">
        <Arg>
          <New class="org.mortbay.util.RolloverFileOutputStream">
            <Arg><SystemProperty name="jetty.logs" default="."/>/yyyy_mm_dd.stderrout.log</Arg>
            <Arg type="boolean">false</Arg>
            <Arg type="int">90</Arg>
            <Arg><Call class="java.util.TimeZone" name="getTimeZone"><Arg>GMT</Arg></Call></Arg>
            <Get id="ServerLogName" name="datedFilename"/>
          </New>
        </Arg>
      </New>

      <Call class="org.mortbay.log.Log" name="info"><Arg>Redirecting stderr/stdout to <Ref id="ServerLogName"/></Arg></Call>
      <Call class="java.lang.System" name="setErr"><Arg><Ref id="ServerLog"/></Arg></Call>
      <Call class="java.lang.System" name="setOut"><Arg><Ref id="ServerLog"/></Arg></Call></Configure>' >> /opt/solr/etc/jetty-logging.xml

# Create the Solr user and grant it permissions
useradd -d /opt/solr -s /sbin/false solr
chown solr:solr -R /opt/solr

# Download the start file and set it to automatically start up if it hasn't been done already
wget --quiet -O /etc/init.d/jetty http://dev.eclipse.org/svnroot/rt/org.eclipse.jetty/jetty/trunk/jetty-distribution/src/main/resources/bin/jetty.sh
chmod a+x /etc/init.d/jetty
update-rc.d jetty defaults

# Change the default collection name and remove data
cd /opt/solr/solr && sudo mv collection1 ckan
cd /opt/solr/solr/ckan && sudo rm -R data
# sed -i.bak 's/name=collection1/name=ckan/' core.properties

# Start Jetty/Solr:
echo "Solr installed! Starting it..."
/etc/init.d/jetty start

