Nuxeo install script for SmartOS Triton
=================================================

install-nuxeo.sh is a bash script that installs Nuxeo in a Triton LX zone.

[Nuxeo](https://en.wikipedia.org/wiki/Nuxeo) is a content management platform.


[Triton](https://docs.joyent.com/private-cloud) is an open-source cloud platform by Joyent.


For a walk through of manually installing Nuxeo, see:
http://blog.smartcore.net.au/nuxeo-ecm-smartos-lx-zone-setup/

To create a zone and install nuxeo, use:
``` shell
triton instance create -w --name=nuxeo ubuntu-14.04 sample-16G --network=sdc_nat --script=./install-nuxeo.sh |tee json.out
```

The ssh server will not begin accepting connections until the
install script completes, which can take five minutes given even
a very fast internet connection for the downloads.  When it
successfully completes, the nuxeo web interface will be running
on port 8080.  The following command should generate the URL.

``` shell
id=$(json -g 0.id<out.json)
fqdn=$(triton inst get $id|json -g 0.dns_names.3)
echo http://$fqdn:8080
```
