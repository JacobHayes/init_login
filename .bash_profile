if [[ ! -f /var/log/init_login.log ]]
then
  printf "Would you like to change your password, manage automatic updates, manage iptables? [Y]/n: "
  read reply
  reply_ip=${reply:-Y}

  if [[ $reply_ip = "n" || $reply_ip = "N" ]]
  then
    echo "Skipping..."
  else
    git clone git://github.com/JacobHayes/init_login.git

    ./init_login/init_login.sh -a
  fi
fi
