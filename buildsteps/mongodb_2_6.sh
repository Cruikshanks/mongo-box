#!/bin/bash -x

# Install MongoDB version 2.6

# Import the public key for the repo
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

# Create a list file for MongoDb
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list

# Update repos
apt-get update

# Install MongoDb
apt-get install --yes mongodb-org=2.6.7 mongodb-org-server=2.6.7 mongodb-org-shell=2.6.7 mongodb-org-mongos=2.6.7 mongodb-org-tools=2.6.7

# Prevent unintended upgrades by pinning
echo "mongodb-org hold" | dpkg --set-selections
echo "mongodb-org-server hold" | dpkg --set-selections
echo "mongodb-org-shell hold" | dpkg --set-selections
echo "mongodb-org-mongos hold" | dpkg --set-selections
echo "mongodb-org-tools hold" | dpkg --set-selections

# Create MongoDB admin user
mongo admin --eval 'db.createUser({user:"adminUser",pwd:"password",roles:[{role:"userAdminAnyDatabase",db:"admin"}]})'

# Configure MongoDB to use authentication
service mongod stop
echo "auth=true" >> /etc/mongod.conf

# Ensure it listens on all interfaces (essential for a Vagrant setup)
sed -i 's/bind_ip = 127.0.0.1/# bind_ip = 127.0.0.1/g' /etc/mongod.conf

# update-rc.d is used for adding and removing services from start up
# This adds a service to startup accepting the defaults for which run levels
# start and stop the service
update-rc.d mongod defaults

# Start MongoDB
service mongod start
