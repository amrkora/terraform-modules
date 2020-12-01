#!/bin/bash
yum update -y
sudo yum install java-1.8.0-openjdk -y
java -version
chmod 700 /tmp/nyoo-services-0.1.jar
nohup java -jar /tmp/nyoo-services-0.1.jar &
