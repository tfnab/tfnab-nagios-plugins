#!/usr/bin/perl

# check_win_snmp_storage.pl
#
# Author: Brent Ashley <brent@ashleyit.com> 31 Oct 2008
#
# Query Windows Server via SNMP for hrStorage data
#
# use to check drives or memory
#
# syntax: check_win_snmp_storage.pl HOST COMMUNITY storageType WARN CRIT
#
# returns % used, bytes total, bytes used, storageType
#
# storageType is one of: PhysicalMemory, VirtualMemory, AllDisks, or a driveletter (A through Z) 
#
# AllDisks returns stats for drive with highest usage %

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

use strict;
use Net::SNMP;

my $host = shift;	
my $community = shift;
my $storageType = shift;
our $WARN = shift;
our $CRIT = shift;	

our %ERRORS = (
	OK => 0,
	WARNING => 1,
	CRITICAL => 2,
	UNKNOWN => 3,
	DEPENDENT => 4
);

unless( $CRIT ) {
	errorExit( "syntax: check_win_snmp_storage.pl HOST COMMUNITY type WARN CRIT" );
}

my %oid = (
	hrStorageEntryTables => '.1.3.6.1.2.1.25.2.3.1',
	hrStorageIndex => '.1.3.6.1.2.1.25.2.3.1.1',
	hrStorageType => '.1.3.6.1.2.1.25.2.3.1.2',
	hrStorageDesc => '.1.3.6.1.2.1.25.2.3.1.3', 
	hrStorageAllocationUnits => '.1.3.6.1.2.1.25.2.3.1.4',
	hrStorageSize => '.1.3.6.1.2.1.25.2.3.1.5',
	hrStorageUsed => '.1.3.6.1.2.1.25.2.3.1.6'
);

my %storageType = (
	'.1.3.6.1.2.1.25.2.1.5' => 'RemovableDisk', 
	'.1.3.6.1.2.1.25.2.1.4' => 'FixedDisk', 
	'.1.3.6.1.2.1.25.2.1.7' => 'CompactDisk', 
	'.1.3.6.1.2.1.25.2.1.3' => 'VirtualMemory', 
	'.1.3.6.1.2.1.25.2.1.2' => 'PhysicalMemory' 
);

# get SNMP session object
my ($snmp, $err) = Net::SNMP->session(
	-hostname => $host,
	-community => $community,
	-port => 161,
	-version => 1 
);
errorExit( $err ) unless (defined($snmp));

# get storage tables
my $response = $snmp->get_table(
	-baseoid => $oid{hrStorageEntryTables}
);
errorExit( "error getting storage tables" ) unless $response;
my %value = %{$response};
$snmp->close();

# find indices
my @indices;
foreach my $key ( keys %value ){
	my( $parent ) = $key =~ /(.*)\.\d+$/;
	push @indices, $value{ $key } if ($parent eq $oid{hrStorageIndex});
}

# build storage definition hash
my %storage;
foreach my $index ( @indices ){
	my $size = $value{ $oid{hrStorageSize} . ".$index" };
	my $used = $value{ $oid{hrStorageUsed} . ".$index" };
	my $pct = $size ? int(100 * $used / $size) : 0;
	$storage{$index} = {
		type => $storageType{ $value{ $oid{hrStorageType} . ".$index" } },
		desc => $value{ $oid{hrStorageDesc} . ".$index" },
		units => $value{ $oid{hrStorageAllocationUnits} . ".$index" },
		size => $size,
		used => $used,
		pct => $pct
	};
}

# memory checks
if( (lc $storageType) eq 'virtualmemory' || (lc $storageType) eq 'physicalmemory') {
	foreach my $item ( values %storage ){
		my %this = %{$item};
		if ( (lc $this{type}) eq (lc $storageType) ) {
			ReportAndExit( 
				$this{pct}, 
				$this{size} * $this{units}, 
				$this{used} * $this{units}, 
				$this{type}
			);
		}
	}
	errorExit( "$storageType type not found" ); 
}

# all disks - report on worst disk
if( (lc $storageType) eq 'alldisks' ){
	my %worst = (
		disk => '',
		pct => 0,
		size => 0,
		used => 0,
		units => 0
	);
	foreach my $item ( values %storage ){
		my %this = %{$item};
		if ( $this{type} eq 'FixedDisk' ) {
			if( $this{pct} > $worst{pct} ) {
				$worst{disk} = uc substr($this{desc},0,1);
				$worst{pct} = $this{pct};
				$worst{size} = $this{size};
				$worst{used} = $this{used};
				$worst{units} = $this{units};
			}
		}
	}
	if ( $worst{disk} ){
		ReportAndExit( 
			$worst{pct}, 
			$worst{size} * $worst{units}, 
			$worst{used} * $worst{units}, 
			'Disk ' . $worst{disk}
		);
	} else {
		errorExit( "no fixed disks found" );
	}
}

# must be a driveletter
if( $storageType =~ /^[a-zA-Z]$/ ) {
	my $drive = uc $storageType;
	foreach my $item ( values %storage ){
		my %this = %{$item};
		if ( ($this{type} eq 'FixedDisk') ) {
			my $thisDrive = uc substr($this{desc},0,1);
			if( $thisDrive eq $drive ){
				ReportAndExit( 
					$this{pct}, 
					$this{size} * $this{units}, 
					$this{used} * $this{units}, 
					"$drive:"
				);
			}
		}
	}
	errorExit( "Driveletter [$drive] not found" );
}

# UNIX mount points
if( $storageType =~ /^\// ) {
	foreach my $item ( values %storage ){
		my %this = %{$item};
		if ( ($this{type} eq 'FixedDisk') ) {
			if( $storageType eq $this{desc} ){
				ReportAndExit( 
					$this{pct}, 
					$this{size} * $this{units}, 
					$this{used} * $this{units}, 
					"$storageType"
				);
			}
		}
	}
	errorExit( "Partition [$storageType] not found" );
}

errorExit( "Invalid storage type $storageType" );

# end of program

sub ReportAndExit {
	my ( $pct, $total, $used, $type ) = @_;
	my $err = ($pct >= $CRIT) ? 'CRITICAL' : ($pct >= $WARN) ? 'WARNING' : 'OK';
	print "$err : Storage Used $pct% : Total $total bytes : Used $used bytes : Type $type\n";
	exit $ERRORS{$err};
}

sub errorExit {
	my $msg = shift;
	print "UNKNOWN: $msg\n";
	exit $ERRORS{UNKNOWN};
}
