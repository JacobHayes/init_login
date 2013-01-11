init_login.sh
========

Script to to preform initial VM setup for the customer on first login


1. First, we prompt the user to update the installed packages through yum or apt-get

2. Next, we prompt to disable the iptables and ip6tables firewalls for easier port management, at the risk of potential decreased security

3. For security, we finally prompt the user to change the password from the randomly generated one
