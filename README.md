Nuxeo install script for SmartOS Triton
=================================================

install-nuxeo.sh is a bash script that installs Nuxeo in a Triton LX zone.

[Nuxeo](https://en.wikipedia.org/wiki/Nuxeo) is a content management platform.


[Triton](https://docs.joyent.com/private-cloud) is an open-source cloud platform by Joyent.


For a walk through of manually installing Nuxeo, see:
http://blog.smartcore.net.au/nuxeo-ecm-smartos-lx-zone-setup/

To create a zone and install nuxeo, use:
``` shell
wget https://raw.githubusercontent.com/zxvv/smartos-nuxeo/master/install-nuxeo.sh
triton instance create -w --name=nuxeo ubuntu-14.04 sample-16G --network=sdc_nat --script=./install-nuxeo.sh
```

When this command completes, the install has not finished, but
rather just started.  The ssh and web servers will not begin
accepting connections until the install script completes, which
can take five minutes given even a very fast internet connection
for the downloads.  When it successfully completes, the nuxeo
web interface will be running on port 8080.

Certain performance tuning is done to improve response time of
the Nuxeo web interface.  This script applies the performance
tuning reported by Nuxeo in a benchmark of a single server
instance storing 10 million documents in 1TB of data, described
here: http://public.dev.nuxeo.com/~ben/bench-10m/

The script silently downloads Java 8 JDK, and doing so requires acceptance of the [Oracle Binary Code License Agreement for Java SE](http://www.oracle.com/technetwork/java/javase/terms/license/index.html).

![Screenshot of Dashboard](/../screenshots/nuxeo-screenshot.gif?raw=true "Screenshot of Dashboard")
