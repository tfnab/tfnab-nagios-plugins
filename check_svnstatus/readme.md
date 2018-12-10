# check_svnstatus

checks a subversion working copy for modifications

## Usage

`check_svnstatus.sh -d WCDIR [ -v ]`

## Requirements

bash script

requires `svn` and `egrep` in one of the directories listed in PATH

## Returns

returns OK when the working copy in WCDIR has not been modified

returns CRITICAL when there are modifications; with -v option: returns list of changes on additional lines, for the $LONGSERVICEOUTPUT$ macro

returns UNKNOWN when WCDIR is not a working copy
