init_login.sh
========

Script to get new system ready for initial use.

```
OPTIONS:
   -a
      Run all steps...

   -m
      Manage auto updates (only CentOS for now) with yum-cron or a cron job

   -p
      Change password...

   -s
      Add ssh keys...

   -t
      Enable or disable `ip(6)tables`...

   -u
      Check/install updates with either `yum` or `apt-get`
```

Future/ToDo
-----------

See the following for ideas/tips on distro ID (shamelessly stealing from Chef/Ohai)
https://github.com/opscode/ohai/blob/master/lib/ohai/plugins/linux/platform.rb

  - Upload/Download pubkeys to authorized_keys
    - Perhaps can run client side to upload keys and script and then run script
    - Or could download pubkeys for a specified location

- Branches:
  - profile_templates
    - Make the profiles templates for deploying instead of running init_login.sh
    - Include shell tweaks, customizations, etc. Maybe include things like [login_metrics](https://github.com/JacobHayes/login_metrics) too
  - devel_languages
    - Add support for `python3` and `rvm`+`ruby` installations as well as `go`. Maybe `haskell` too
    - Include dependency support, ex `brew` et al on OS X
  - server_config
    - Add support for service config/hardening (ex `sshd`, `ftp`)
    - Perhaps support for things like Apache/nginx, though I think that starts to be Chef's place
