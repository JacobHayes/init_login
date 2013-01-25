init_login.sh
========

Script to to preform initial VM setup for the customer on first login


1. For security, we finally prompt the user to change the password

2. Next, we perform updates with yum or apt-get if available. Then we ask to enable/disable automatic updates

3. Lastly, we prompt to disable the iptables and ip6tables firewalls for easier port management, at the risk of potential decreased security
