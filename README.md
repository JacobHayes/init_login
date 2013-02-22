init_login.sh
========

Script to get new VM ready for initial use.

```
OPTIONS:
   -a
      Run all steps...

   -m
      Manage auto updates (only CentOS for now) with yum-cron or a cron job

   -p
      Change password...

   -t
      Enable or disable ip(6)tables...

   -u
      Check/install updates with either yum or apt-get
```

Future...
========

I might add the ability to upload id_rsa.pubs to the remote host, in which case another script would run locally to upload the id_rsa.pub=>authorized_keys to the remote host and then scp init_login.sh to the remote host and run it there.

License
========

Copyright (C) 2013 Jacob Hayes

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
