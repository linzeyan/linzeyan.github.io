#!/usr/bin/env bash

# change it
hostName='super-api'
remoteHost="1.1.1.1"
privKey="~/.ssh/aws/ec2.pem"

composeUrl='https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-linux-x86_64'
remoteUser=ubuntu
sshHost="${remoteUser}@${remoteHost}"

set -e

_common() {
    ssh -i ${privKey} ${sshHost} sudo 'apt-get update && sudo apt-get upgrade -y'
    ssh -i ${privKey} ${sshHost} 'sudo timedatectl set-timezone Asia/Taipei'
    ssh -i ${privKey} ${sshHost} "sudo hostnamectl hostname \"${hostName}\""
}

_docker() {
    ssh -i ${privKey} ${sshHost} 'sudo apt-get install docker.io -y'
    ssh -i ${privKey} ${sshHost} "sudo wget \"${composeUrl}\" -O /usr/local/bin/docker-compose"
    ssh -i ${privKey} ${sshHost} 'sudo chmod +x /usr/local/bin/docker-compose'
}

_nginx() {
    sudo apt-get install nginx certbot python3-certbot-nginx
}

_nginx_cert() {
    sudo certbot --nginx
}

_common
