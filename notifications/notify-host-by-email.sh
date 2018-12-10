#!/bin/bash

FROMADDRESS="nagios@`hostname --fqdn`"

if [ "0" -eq $NAGIOS_HOSTPROBLEMID ]
then
	PROBLEMID=$NAGIOS_LASTHOSTPROBLEMID
else
	PROBLEMID=$NAGIOS_HOSTPROBLEMID
fi

/usr/sbin/sendmail -f $FROMADDRESS $NAGIOS_CONTACTEMAIL <<END-OF-NOTIFICATION
Content-Type: text/plain
From: $FROMADDRESS
To: $NAGIOS_CONTACTEMAIL
Subject: ** [$PROBLEMID] $NAGIOS_NOTIFICATIONTYPE: $NAGIOS_HOSTNAME is $NAGIOS_HOSTSTATE **
Date: `date -R`
References: <nagios-problem-id-$PROBLEMID-@`hostname --fqdn`>

$NAGIOS_HOSTOUTPUT
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

Date/Time:         $NAGIOS_LONGDATETIME

// this notification was created using notify-host-by-email.sh _r2
END-OF-NOTIFICATION
