#!/bin/bash
sudo yum -y update
sudo amazon-linux-extras install nginx -y
sudo aws s3 cp s3://runalshbucket/index.html /usr/share/nginx/html/index.html
sudo systemctl restart nginx
sudo systemctl enable nginx





