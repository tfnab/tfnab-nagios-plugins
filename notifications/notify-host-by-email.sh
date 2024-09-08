#!/bin/bash

# Plugin Name: notify-host-by-email.sh
# Version: 0.5
# Author: Martin Lormes
# Author URI: http://ten-fingers-and-a-brain.com

# Copyright (c) 2011-2024 Martin Lormes
#
# This program is free software; you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free Software 
# Foundation; either version 3 of the License, or (at your option) any later 
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with 
# this program. If not, see <http://www.gnu.org/licenses/>.

FROMADDRESS="nagios@`hostname --fqdn`"

if [ "0" -eq $NAGIOS_HOSTPROBLEMID ]
then
	PROBLEMID=$NAGIOS_LASTHOSTPROBLEMID
else
	PROBLEMID=$NAGIOS_HOSTPROBLEMID
fi

T_TOPIC="** $NAGIOS_HOSTNAME ** [$PROBLEMID]"

/usr/sbin/sendmail -f $FROMADDRESS $NAGIOS_CONTACTEMAIL <<END-OF-NOTIFICATION
Content-Type: text/plain
From: $FROMADDRESS
To: $NAGIOS_CONTACTEMAIL
Subject: $NAGIOS_NOTIFICATIONTYPE: $T_TOPIC
Thread-Topic: $T_TOPIC
Date: `date -R`
References: <nagios-problem-id-$PROBLEMID-@`hostname --fqdn`>

$NAGIOS_NOTIFICATIONTYPE: $NAGIOS_HOSTSTATE -- $NAGIOS_HOSTOUTPUT
$NAGIOS_LONGHOSTOUTPUT

* * * * * Nagios * * * * *

Notification Type: $NAGIOS_NOTIFICATIONTYPE
Problem ID:        $PROBLEMID
Notification No.:  $NAGIOS_HOSTNOTIFICATIONNUMBER
State:             $NAGIOS_HOSTSTATE
Duration:          $NAGIOS_HOSTDURATION

Host:              $NAGIOS_HOSTNAME
Host Alias:        $NAGIOS_HOSTALIAS
Address:           $NAGIOS_HOSTADDRESS
Notes:             $NAGIOS_HOSTNOTESURL

Date/Time:         $NAGIOS_LONGDATETIME

// this notification was created using notify-host-by-email.sh _r5
END-OF-NOTIFICATION
