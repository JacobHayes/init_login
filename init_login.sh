#!/bin/bash
####################################################################################################
# Jacob Hayes - login.sh
####################################################################################################
#
# Script to get the system ready for initial use
#
# For security, we first prompt the user to change the password from the randomly generated one
#
# Secondly, if updates are available, we prompt for install through yum or apt-get
# We also prompt if they would like security or normal automatic updates and if not we setup
# scheduled update checks and then mail the user when updates are found.
#
# Finally, we prompt to disable the iptables and ip6tables firewalls for easier port management, at
# the risk of potential decreased security
#
####################################################################################################

function ECHO 
{
   message=$1

   echo "$message" | tee -a $logfile
}

clear

if [[ `whoami` != "root" ]]
then
   ECHO "This script must be run as root!"
   exit 1
fi

logfile=/var/log/init_login.log

touch $logfile
chmod 644 $logfile

if [[ -f /etc/centos-release ]]
then
   distro="centos"

   ECHO "Proudly supporting CentOS"
elif [[ -f /etc/lsb-release ]]
then
   distro="ubuntu"

   ECHO "Proudly supporting Ubuntu"
else
   ECHO "Unknown distro!"

   exit 1
fi

ECHO ""
ECHO ""

#Prompt for password change on first login
ECHO "For security reasons, please change your password. If you would prefer not to, press CTRL-C"
ECHO "NOTE: We will not have your new password, and cannot recover it. Keep it safe!"

trap 'ECHO Skipping password change... | tee -a $logfile && stty echo' SIGINT
passwd -f root | tee -a $logfile
trap - SIGINT

ECHO ""
ECHO ""

if [[ $distro = "centos" ]]
then
   yumtmp="/tmp/yum_chk_upd"

   yum check-update >& $yumtmp

   num_upd=`cat $yumtmp | egrep '(.i386|.x86_64|.noarch|.src)' | wc -l`

   if (( num_upd > 0 ))
   then
      ECHO "$num_upd updates available."
      update=`yum -y update >> $logfile`
   fi

   rm $yumtmp
elif [[ $distro = "ubuntu" ]]
then
   apt-get update >& /dev/null 
   num_upd=`apt-show-versions -u | wc -l`

   if (( $num_upd > 0 ))
   then
      ECHO "$num_upd updates available."
      update=`apt-get -y upgrade >> $logfile`
   fi
fi

if [[ -z $update ]]
then
   ECHO "Yay! No updates available!"
else
   #Ask if they want to update installed packages
   printf "Would you like to update installed packages? Y/[N]: " | tee -a $logfile
   read reply_upd
   reply_upd=${reply_upd:-N}

   echo $reply_upd >> $logfile

   if [[ $reply_upd == "n" || $reply_upd == "N" ]]
   then
      ECHO ""
      ECHO "Skipping updates..."
   elif [[ $reply_upd == "y" || $reply_upd == "Y" ]]
   then
      ECHO ""
      ECHO "Preforming updates..."

      $update
   fi
fi

ECHO ""
ECHO ""

##########
#Need to get the auto-updates finished...
##########

#Ask about automatic updating
#ECHO "Automatic updates will keep software up to date, but may add or change functionality."
#ECHO "This could break existing scripts or workflows, but may also fix security flaws."
#ECHO "Would you like to disable updates, enable security updates, or enable all automatic updates? [D]/S/A"

#echo "This needs to be finished..."

#IF CENTOS: Ask if they would like to disable iptables and ip6tables for easier networking
if [[ $distro = "centos" ]] && [[ `service iptables status | grep -c "Table: filter"` == 1 || `service ip6tables status | grep -c "Table: filter"` == 1  ]]
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
ECHO "####################################################################################################"
ECHO "                                 Done! Have fun with your new server!                               "
ECHO "####################################################################################################"
