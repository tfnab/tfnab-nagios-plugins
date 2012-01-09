# Nagios Plugins

## check_svnstatus

checks a subversion working copy for modifications

### Usage

check_svnstatus.sh -d WCDIR

### Requirements

bash script

requires svn and egrep in one of the directories listed in PATH

### Returns

returns OK when the working copy in WCDIR has not been modified

returns CRITICAL when there are modifications

returns UNKNOWN when WCDIR is not a working copy
