# check_ilo2_health

check HPE server health by querying the iLO board

forked from https://exchange.nagios.org/directory/Plugins/Hardware/Server-Hardware/HP-(Compaq)/check_ilo2_health/details

modified to use `Monitoring::Plugin` instead of `Nagios::Plugin` which is no longer available on recent versions of Ubuntu

## Installation of required Perl modules on Ubuntu

```
sudo apt-get install libmonitoring-plugin-perl libio-socket-ssl-perl libxml-simple-perl
```
