# check_snmp_storage

check storage space through SNMP

forked from https://exchange.nagios.org/directory/Plugins/Operating-Systems/Windows/check_win_snmp_storage-2Epl/details

## Installation of SNMP service on Windows 2008 R2

```
Import-Module ServerManager
Add-WindowsFeature SNMP-Services
```

## Installation of SNMP service on Windows 2012 and newer

```
Add-WindowsFeature -Name SNMP-Service -IncludeManagementTools
```

## Installation and configuration of SNMP daemon on Debian or Ubuntu

```
sudo apt-get update
sudo apt-get install snmpd
```

Then edit `/etc/snmp/snmpd.conf`:

comment out
```
#agentAddress  udp:127.0.0.1:161
```

uncomment
```
agentAddress udp:161,udp6:[::1]:161
```

add the last two lines to the following section

```
                                                 #  system + hrSystem groups only
view   systemonly  included   .1.3.6.1.2.1.1
view   systemonly  included   .1.3.6.1.2.1.25.1
                                                 #  hrStorage
view   systemonly  included   .1.3.6.1.2.1.25.2
```

Then

```
sudo service snmpd restart
```

## Installation and configuration of SNMP daemon on openSUSE

```
zypper in net-snmp
snmpconf -i
rcsnmpd start
insserv ###
```
