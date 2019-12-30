#!/bin/sh
if [ ! -d .ssh ]; then 
    mkdir /home/ec2-user/.ssh
    chmod 700 /home/ec2-user/.ssh
fi

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDbgiVjmRu57uCdWXlzm//XV9QRS/4tpjc96SbtZNTQaT5PNZX/HGIZvGHDVWF1dZ3e2VP65YaF4CXAXyy9WLQzVyh3VtgTMl7xChB9ZCI9fj+jmn1j89EPzEykm/GiwchMJSU0+GsvpUvXRi1lDC4K2nXWJM7HRtS0x2wxqOrPcl2I/22HI8aNBs5/zOQQ4vC+r9JNzD8AGmn9aVjt3WMF7FBCeqIx6TYuTwg1v7+rm9iu0qW7L5empufuaDpY6mCyG2wGxbUKuPc/M4yUW4zOFbkhozpUOPISg0XZ4XkcTF8gODtkIY/lpLKWeCnZQQooWeI9f5Qu91KQ81QDZeWkRxSA9d0mPumUUBpApk34ib3pHm1o2x1t+BvbHuqgSykXBXKwOWttcqGw76omhJHCrielsJvjdsSYdRm9g2qN9amaCZ1i2IsmOWPDz1GiqlDdbutGBfwgacgGgzBRMDWx2sDl+I+4mfaa8Qfxrnku1p+iUUjEDVG2Yj21pWXzAc0=" > /home/ec2-user/.ssh/authorized_keys

chmod 600 /home/ec2-user/.ssh/authorized_keys
chown -R ec2-user: /home/ec2-user/.ssh

sudo yum update -y

sudo yum install docker git -y
#sudo yum install gcc openssl-devel bzip2-devel -y
sudo yum install python2 wget -y
wget https://bootstrap.pypa.io/get-pip.py
sudo python2 get-pip.py

sudo ln -sf /usr/bin/python2.7 /etc/alternatives/python
sudo ln -sf /etc/alternatives/python /usr/bin/python

sudo pip install ansible

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

sudo yum install jenkins -y
yum install maven -y

yum install java-1.8.0-openjdk-devel