#Docker Installation of Netdisco

https://metacpan.org/pod/App::Netdisco

Use Docker-Compose and included yml config file for easy startup of both DB and Netdisco


####Modify deployment.yml changes after initial startup for additional features
https://metacpan.org/pod/distribution/App-Netdisco/lib/App/Netdisco/Manual/Configuration.pod
```
# Add LDAP Config Settings
ldap:
   servers:  
     - 'dc1.dns'  
     - 'dc2.dns'  
   user_string: 'MYDOMAIN\%USER%'  
   base: <base dn>  
   opts:  
     debug: 3

# Inventory all MACs on all VLANS.
macsuck_all_vlans: true

reports:
  - tag: power_inventory
    label: 'Power Supply Inventory'
    category: Device
    columns:
      - {name: 'Name'}
      - {ps1_type: 'PS1 Type'}
      - {ps1_status: 'PS1 Status'}
    query: |
      SELECT d.name, d.ps1_type, d.ps1_status
        FROM device d
        WHERE d.ps1_status<>''
          AND d.ps1_status is not null
      ORDER BY name

port_control_reasons:
  address:     'Address Allocation Abuse'
  copyright:   'Copyright Violation'
  dos:         'Denial of Service'
  bandwidth:   'Excessive Bandwidth'
  polling:     'Excessive Polling of DNS/DHCP/SNMP'
  noserv:      'Not In Service'
  exploit:     'Remote Exploit Possible'
  compromised: 'System Compromised'
  other:       'Other'
  resolved:    'Issue Resolved'

discover_min_age: 300

macsuck_unsupported_type:
  - 'cisco\s+AIR-LAP'
  - '(?i)Cisco\s+IP\s+Phone'
```
