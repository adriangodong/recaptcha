If you have firewall ACLs, you must allow access to all all Google IP addresses. We strongly recommend that you either a) allow outbound access to all IPs on port 80 or b) use a proxy server to do access control based on host name.

The reCAPTCHA servers can be located on any IP address owned by Google. While we can not provide official support for IP Address-based ACLs, Google's public IP space can be found by issuing the following command from a Linux/Unix box:

```
dig -t TXT _netblocks.google.com
```

The result right now is:

```
ip4:216.239.32.0/19
ip4:64.233.160.0/19
ip4:66.249.80.0/20
ip4:72.14.192.0/18
ip4:209.85.128.0/17
ip4:66.102.0.0/20
ip4:74.125.0.0/16
ip4:64.18.0.0/20
ip4:207.126.144.0/20
ip4:173.194.0.0/16
```

but you should periodically check this, as these blocks may occasionally change.