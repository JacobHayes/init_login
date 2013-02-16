#!/usr/bin/env bash
####################################################################################################
# Jacob Hayes - init_login.sh
####################################################################################################
#
#Copyright (C) 2013 Jacob Hayes
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
#associated documentation files (the "Software"), to deal in the Software without restriction, 
#including without limitation the rights to use, copy, modify, merge, publish, distribute, 
#sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial
#portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
#NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
#NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
#OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
#CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
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

#####################
#Universal Functions#
#####################

function ECHO 
{
   message=$1

   echo "$message" | tee -a $logfile
}

function USAGE
{
   echo "
############
SCRIPT USAGE
############

Script to get new VM ready for initial use.

OPTIONS:
   -a
      Run all steps...
   -m
      Manage auto updates...
   -p
      Change password...
   -t
      Enable or disable ip(6)tables...
   -u
      Check/install updates...
"

   exit 1
}

###################
#Program Functions#
###################

function AUTO_UP
{
   ECHO ""
   ECHO ""

   #Ask about automatic updating
   if [[ $distro = "centos" ]]
   then
      ECHO "Automatic updates will keep software up to date, but may add or change functionality."
      ECHO "This could break existing scripts or workflows, but may also fix security flaws."
      printf "Would you like to disable updates, enable security updates, or enable all automatic updates? [D]/S/A: "
      read reply_au 
      reply_au=${reply_au:-D}

      echo $reply_au >> $logfile
      ECHO ""

      if [[ $reply_au = "d" || $reply_au = "D" ]]
      then
         ECHO "Disabling automatic updates..."

         if [[ -f "/etc/init.d/yum-cron" ]]
         then
            yum erase -y --remove-leaves yum-cron >> $logfile
         fi

         ECHO "I should probably make this check for the security updates and disable them if installed."
      elif [[ $reply_au = "s" || $reply_au = "S" ]]
      then
         ECHO "Enabling automatic security updates..."

         up_script="/etc/cron.daily/secure_update"
         touch $up_script
         chmod 755 $up_script

         echo "#!/bin/bash" >> $up_script
         echo "DAYS=1" >> $up_script
         echo "" >> $up_script
         echo "/usr/bin/yum update -y --security" >> $up_script

         ECHO "STILL NOT QUITE SURE IF THE ABOVE"
         ECHO "ACTUALLY GETS THE JOB DONE..."

      elif [[ $reply_au = "a" || $reply_au = "A" ]]
      then
         ECHO "Enabling automatic updates..."

         yum install -y yum-cron >> $logfile
         service yum-cron start >> $logfile
         chkconfig yum-cron on >> $logfile

         ECHO "Config file: /etc/sysconfig/yum-cron"
      fi
   elif [[ $distro = "ubuntu" ]]
   then
      ECHO "Automatic updates are not yet configured for Ubuntu..."
   fi

   ECHO "Done!"
}

function IPTABLES
{
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
         ECHO "Starting iptables and ip6tables..."

         service iptables start >> $logfile
         service ip6tables start >> $logfile

         ECHO "Enabling iptables and ip6tables..."

         chkconfig iptables on >> $logfile
         chkconfig ip6tables on >> $logfile

      elif [[ $reply_ip = "y" || $reply_ip = "Y" ]]
      then
         ECHO ""
         ECHO "Stopping iptables and ip6tables..."

         service iptables stop >> $logfile
         service ip6tables stop >> $logfile

         ECHO "Disabling iptables and ip6tables..."

         chkconfig iptables off >> $logfile
         chkconfig ip6tables off >> $logfile
      fi

   elif [[ $distro = "ubuntu" ]]
   then
      ECHO "Ubuntu's iptables and ip6tables are passive by default. No action is required."
   fi

   ECHO "Done!"
}

function PASSWORD 
{
   ECHO ""
   ECHO ""
   #Prompt for password change
   ECHO "For security reasons, please change your password. If you would prefer not to, press CTRL-C"
   ECHO "NOTE: We will not have your new password, and cannot recover it. Keep it safe!"

   trap 'ECHO Skipping password change... | tee -a $logfile && stty echo' SIGINT
   passwd -f root | tee -a $logfile
   trap - SIGINT

   ECHO "Done!"
}

function UPDATES
{
   ECHO""
   ECHO ""
   ECHO "Checking for updates..."

   if [[ $distro = "centos" ]]
   then
      num_upd=`yum check-update | egrep '(.i386|.x86_64|.noarch|.src)' | wc -l`

      if (( num_upd > 0 ))
      then
         ECHO "$num_upd updates available."
         update="yum -y update >> $logfile"
      fi

   elif [[ $distro = "ubuntu" ]]
   then
      apt-get update >& /dev/null 
      num_upd=`apt-show-versions -u | wc -l`

      if (( $num_upd > 0 ))
      then
         ECHO "$num_upd updates available."
         update="apt-get -y upgrade >> $logfile"
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

   ECHO "Done!"
}


############
#Main Calls#
############

clear

if [[ `whoami` != "root" ]]
then
   ECHO "This script must be run as root!"
   exit 1
fi

logfile=/var/log/init_login.log

printf "" > $logfile
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

while getopts ":amptu" opt
do
   case $opt in
      a)
         PASSWORD
         UPDATES
         AUTO_UP
         IPTABLES
         flag="a"
         ;;
      m)
         AUTO_UP
         flag="m"
         ;;
      p)
         PASSWORD
         flag="p"
         ;;
      t)
         IPTABLES
         flag="t"
         ;;
      u)
         UPDATES
         flag="u"
         ;;
      ?)
         ECHO ""
         ECHO "Invalid option: -$OPTARG" >&2
         USAGE
         ;;
   esac
done

if [[ -z $flag ]]
then
   USAGE
fi

ECHO ""
ECHO ""
ECHO "####################################################################################################"
ECHO "                                 Done! Have fun with your server!                                   "
ECHO "####################################################################################################"