#!/usr/bin/env bash

# DOCKER

sudo su

password

e

curl -fsSL https://get.docker.com/ | sh

systemctl start docker

systemctl status docker

systemctl enable docker



#PROMETHEUS
#############################################
### Step 1 — Installing Prometheus Server ###
#############################################

# First, create a new directory to store all the files you download in this tutorial and move to it.
mkdir ~/Downloads

# Enter the directory you just created.
cd ~/Downloads

# Use curl to download the latest build of the Prometheus server and time-series database from GitHub.
curl -LO "https://github.com/prometheus/prometheus/releases/download/0.16.0/prometheus-0.16.0.linux-amd64.tar.gz"

# The Prometheus monitoring system consists of several components, each of which needs to be installed separately. Keeping all the components inside one parent directory is a good idea, so create one using mkdir.
mkdir ~/Prometheus

# Enter the directory you just created.
cd ~/Prometheus

# Use tar to extract prometheus-0.16.0.linux-amd64.tar.gz.
tar -xvzf ~/Downloads/prometheus-0.16.0.linux-amd64.tar.gz

# This completes the installation of Prometheus server. Verify the installation by typing in the following command:
~/Prometheus/prometheus-0.16.0.linux-amd64/prometheus -version

#########################################
### Step 2 — Installing Node Exporter ###
#########################################

# Enter the Downloads directory and use curl to download the latest build of Node Exporter which is available on GitHub.
cd ~/Downloads && curl -LO "https://github.com/prometheus/node_exporter/releases/download/0.11.0/node_exporter-0.11.0.linux-amd64.tar.gz"

# Create a new directory called node_exporter inside the Prometheus directory, and get inside it:
mkdir ~/Prometheus/node_exporter
cd ~/Prometheus/node_exporter

# You can now use the tar command to extract node_exporter-0.11.0.linux-amd64.tar.gz.
tar -xvzf ~/Downloads/node_exporter-0.11.0.linux-amd64.tar.gz

###################################################
### Step 3 — Running Node Exporter as a Service ###
###################################################

cat > /etc/systemd/system/node_exporter.service << EOF1
[Unit]
Description=Node Exporter

[Service]
User=prometheus
ExecStart=/home/prometheus/Prometheus/node_exporter/node_exporter

[Install]
WantedBy=default.target
EOF1

# Reload systemd so that it reads the configuration file you just created.
systemctl daemon-reload

# At this point, Node Exporter is available as a service which can be managed using the systemctl command. Enable it so that it starts automatically at boot time.
systemctl enable node_exporter.service

# You can now either reboot your server, or use the following command to start the service manually:
systemctl start node_exporter.service

###########################################
### Step 4 — Starting Prometheus Server ###
###########################################

# Enter the directory where you installed the Prometheus server:
cd ~/Prometheus/prometheus-0.16.0.linux-amd64

# Before you start Prometheus, you must first create a configuration file for it called prometheus.yml.
cat > ~/Prometheus/prometheus-0.16.0.linux-amd64/prometheus.yml << EOF1
scrape_configs:
  - job_name: "node"
    scrape_interval: "15s"
    target_groups:
    - targets: ['localhost:9100']
EOF1

# Start the Prometheus server as a background process.
nohup ./prometheus > prometheus.log 2>&1 &

# Note that you redirected the output of the Prometheus server to a file called prometheus.log. You can view the last few lines of the file using the tail command:
tail ~/Prometheus/prometheus-0.16.0.linux-amd64/prometheus.log

####################################
### Step 5 — Installing PromDash ###
####################################

# Enter the Prometheus directory:
cd ~/Prometheus

# PromDash is a Ruby on Rails application whose source files are available on GitHub. In order to download and run it, you need to install Git, Ruby and a few build tools. Use yum to do so.
yum install -y git ruby ruby-devel sqlite-devel zlib-devel gcc gcc-c++ automake patch

# You can now use the git command to download the source files.
git clone https://github.com/prometheus/promdash.git

# Enter the promdash directory.
cd ~/Prometheus/promdash

# PromDash depends on several Ruby gems. In order to automate the installation of those gems, you should install a gem called bundler.
gem install bundler

# You can now use the bundle command to install all the Ruby gems that PromDash requires. As we will be configuring PromDash to work with SQLite3 in this tutorial, make sure you exclude the gems for MySQL and PostgreSQL using the --without parameter:
bundle install --without mysql postgresql

#################################################
### Step 6 — Setting Up the Rails Environment ###
#################################################

# Create a directory to store the SQLite3 databases associated with PromDash.
mkdir ~/Prometheus/databases

# PromDash uses an environment variable called DATABASE_URL to determine the name of the the database associated with it. Type in the following so that PromDash creates a SQLite3 database called mydb.sqlite3 inside the databases directory:
echo "export DATABASE_URL=sqlite3:$HOME/Prometheus/databases/mydb.sqlite3" >> ~/.bashrc

# In this tutorial, you will be running PromDash in production mode, so set the RAILS_ENV environment variable to production.
echo "export RAILS_ENV=production" >> ~/.bashrc

# Apply the changes we made to the .bashrc file.
. ~/.bashrc

# Next, create PromDash's tables in the SQLite3 database using the rake tool.
rake db:migrate

# Because PromDash uses the Rails Asset Pipeline, all the assets(CSS files, images and Javascript files) of the PromDash project should be precompiled. Type in the following to do so:
rake assets:precompile

##################################################
### Step 7 — Starting and Configuring PromDash ###
##################################################

# PromDash runs on Thin, a light-weight web server. Start the server as a daemon by typing in the following command:
bundle exec thin start -d

# Selinux
cat > /etc/sysconfig/selinux << EOF1
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#       enforcing - SELinux security policy is enforced.
#       permissive - SELinux prints warnings instead of enforcing.
#       disabled - SELinux is fully disabled.
SELINUX=permissive
# SELINUXTYPE= type of policy in use. Possible values are:
#       targeted - Only targeted network daemons are protected.
#       strict - Full SELinux protection.
SELINUXTYPE=targeted

# SETLOCALDEFS= Check local definition changes
SETLOCALDEFS=0
EOF1
