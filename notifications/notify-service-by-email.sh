#!/bin/bash

FROMADDRESS="nagios@`hostname --fqdn`"

if [ "0" -eq $NAGIOS_SERVICEPROBLEMID ]
then
	PROBLEMID=$NAGIOS_LASTSERVICEPROBLEMID
else
	PROBLEMID=$NAGIOS_SERVICEPROBLEMID
fi

/usr/sbin/sendmail -f $FROMADDRESS $NAGIOS_CONTACTEMAIL <<END-OF-NOTIFICATION
Content-Type: text/plain
From: $FROMADDRESS
To: $NAGIOS_CONTACTEMAIL
Subject: ** [$PROBLEMID] $NAGIOS_NOTIFICATIONTYPE: $NAGIOS_HOSTNAME/$NAGIOS_SERVICEDESC is $NAGIOS_SERVICESTATE **
Date: `date -R`
References: <nagios-problem-id-$PROBLEMID-@`hostname --fqdn`>

$NAGIOS_SERVICEOUTPUT
$NAGIOS_LONGSERVICEOUTPUT

* * * * * Nagios * * * * *

Notification Type: $NAGIOS_NOTIFICATIONTYPE
Problem ID:        $PROBLEMID
Notification No.:  $NAGIOS_SERVICENOTIFICATIONNUMBER
State:             $NAGIOS_SERVICESTATE
Duration:          $NAGIOS_SERVICEDURATION

Host:              $NAGIOS_HOSTNAME
Host Alias:        $NAGIOS_HOSTALIAS
Address:           $NAGIOS_HOSTADDRESS

Service:           $NAGIOS_SERVICEDESC

Date/Time:         $NAGIOS_LONGDATETIME

// this notification was created using notify-service-by-email.sh _r3
END-OF-NOTIFICATION
