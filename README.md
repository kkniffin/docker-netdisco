Docker Installation of Netdisco

https://metacpan.org/pod/App::Netdisco

Use Docker-Compose and included yml config file for easy startup of both DB and Netdisco

deployment.yml changes after initial startup

```# Add LDAP Config Settings
ldap:
   servers:
     - 'dc1.dns'
     - 'dc2.dns'
   user_string: 'MYDOMAIN\%USER%'
   base: <base dn>
   opts:
     debug: 3```

# Inventory all MACs on all VLANS.
macsuck_all_vlans: true
