#!/bin/sh

sudo yum update -y

# install puppet repo
sudo rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm

# install puppet agent
sudo yum install -y puppet-agent

# install r10k from Ruby Gems
sudo /opt/puppetlabs/puppet/bin/gem install r10k

# download external puppet modules
DIR=$(dirname $0)
cd $DIR
sudo /opt/puppetlabs/puppet/bin/r10k puppetfile install

