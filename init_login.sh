#!/usr/bin/env bash
####################################################################################################
# Jacob Hayes - login.sh
####################################################################################################
#
# Script to get the system ready for initial use
#
# First, we prompt the user to update the installed packages through yum or apt-get
#
# Next, we prompt to disable the iptables and ip6tables firewalls for easier port management, at
# the risk of potential decreased security
#
# For security, we finally prompt the user to change the password from the randomly generated one
####################################################################################################

function ECHO 
{
   message=$1

   echo "$message" | tee -a $logfile
}

clear

user=`whoami`

if [[ $user != "root" ]]
then
   ECHO "This script must be run as root!"
   exit 1
fi

script=`echo "${0}" | sed -e 's/...$//'`
logfile=${script}.log

if [[ -f $logfile ]]
then
   rm -f $logfile
fi

touch $logfile
chmod 644 $logfile

if [[ -f /etc/centos-release ]]
then
   distro="centos"

   ECHO "Proudly supporting CentOS"
else
   distro="ubuntu"

   ECHO "Proudly supporting Ubuntu"
fi

ECHO ""
ECHO ""

#Ask if they want to update installed packages
printf "Would you like to update installed packages? Y/[N]: " | tee -a $logfile
read reply_up
reply_up=${reply_up:-N}

echo $reply_up >> $logfile

if [[ $reply_up == "n" || $reply_up == "N" ]]
then
   ECHO ""
   ECHO "Skipping updates..."
elif [[ $reply_up == "y" || $reply_up == "Y" ]]
then
   ECHO ""
   ECHO "Preforming updates..."

   if [[ $distro = "centos" ]]
   then
      ECHO ""

      yum -y update >> $logfile
   elif [[ $distro = "ubuntu" ]]
   then
      ECHO ""

      apt-get -y update >> $logfile
      apt-get -y upgrade >> $logfile
   fi
fi

ECHO ""
ECHO ""

#IF CENTOS: Ask if they would like to disable iptables and ip6tables for easier networking
if [[ $distro = "centos" ]]
then
   ECHO "Would you like to disable iptables and ip6tables? They act as a firewall blocking incoming connections."
   ECHO "They impove you server's security, though they can be difficult to manage without prior experience."
   ECHO "We use router-based firewalls and only open ports for crucial services, so these are often times redundent."
   printf "Would you like to disable iptables and ip6tables? Y/[N]: " | tee -a $logfile
   read reply_ip
   reply_ip=${reply_ip:-N}

   echo $reply_ip >> $logfile

   if [[ $reply_ip = "n" || $reply_ip = "N" ]]
   then
      ECHO ""
      ECHO "Keeping iptables and ip6tables in place..."
   elif [[ $reply_ip = "y" || $reply_ip = "Y" ]]
   then
      ECHO ""
      ECHO "Stopping iptables and ip6tables..."
      ECHO ""

      service iptables stop >> $logfile
      service ip6tables stop >> $logfile

      chkconfig iptables off >> $logfile
      chkconfig ip6tables off >> $logfile
   fi
fi

ECHO ""
ECHO ""

#Prompt for password change on first login
ECHO "For security reasons, please change your password. If you would prefer not to, press CTRL-C"
ECHO "NOTE: We will not have your new password, and cannot recover it. Keep it safe!"
passwd -f $user | tee -a $logfile

ECHO ""
ECHO "####################################################################################################"
ECHO "                                 Done! Have fun with your new server!                               "
ECHO "####################################################################################################"
