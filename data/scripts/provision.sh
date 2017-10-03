#!/usr/bin/env bash

ensure_jenkins_ready () {
  # wait at most 30 seconds for jenkins to start up
  count=0
  while true; do
    echo "curl -s -w '%{http_code}' http://localhost:8080 ..."
    status=$(curl -s -w "%{http_code}" http://localhost:8080 -o /dev/null)
    if [[ ${status} != "403" ]]; then
      echo "status=${status} Jenkins is not ready. Wait 1 sec ..."
      if [ ${count} -eq 30 ] ; then
          echo "exceeded 30 secs, abort..."
          exit 1
      fi
      sleep 1
      count=$(( count + 1 ))
    else
      echo "status=${status} Jenkins is ready after ${count} seconds :-)"
      break
    fi
  done
}

username=$1
password=$2

wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
sudo dpkg -i puppetlabs-release-pc1-xenial.deb
sudo apt-get update

sudo apt-get install -y puppet-agent
sudo /opt/puppetlabs/bin/puppet module install rtyler/jenkins
sudo /opt/puppetlabs/bin/puppet apply /tmp/puppet/ec2/manifests/init.pp

ensure_jenkins_ready

# create jenkins user
echo -n 'admin:' > /tmp/credential; sudo cat /var/lib/jenkins/secrets/initialAdminPassword >> /tmp/credential
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount('${username}', '${password}')"
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount('${username}', '${password}')" | java -jar /usr/share/jenkins/jenkins-cli.jar -auth @/tmp/credential -s http://localhost:8080/ groovy =
rm -f /tmp/credential
