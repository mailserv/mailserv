#!/usr/bin/perl
#-----------------------------------------------------------------------------
# TimeZone AWStats plugin
# Allow AWStats to correct a bad timezone for user of IIS that use strange
# log format.
#-----------------------------------------------------------------------------
# Perl Required Modules: None
#-----------------------------------------------------------------------------
# $Revision: 1.10 $ - $Author: eldy $ - $Date: 2004/07/11 10:44:41 $


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!! This plugin reduces AWStats speed by 40% !!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
#use Time::Local 'timelocal_nocheck';
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="5.1";
my $PluginHooksFunctions="ChangeTime GetTimeZoneTitle";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$PluginTimeZoneSeconds
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_timezone {
	my $InitParams=shift;

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	if (! $InitParams || int($InitParams) == 0) { return "Error: Disable plugin if TimeZone is 0 (Plugin useless)"; }	# We do not need this plugin if TZ=0
	$PluginTimeZoneSeconds=(int($InitParams)*3600);
	# ----->

	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ChangeTime_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
#-----------------------------------------------------------------------------
sub ChangeTime_timezone {
	my $dateparts=shift;
	my ($nsec,$nmin,$nhour,$nmday,$nmon,$nyear,$nwday) = localtime(Time::Local::timelocal(int(@$dateparts[5]), int(@$dateparts[4]), int(@$dateparts[3]), int(@$dateparts[0]), int(@$dateparts[1])-1, int(@$dateparts[2])-1900) + $PluginTimeZoneSeconds);
	return ($nmday, $nmon+1, $nyear+1900, $nhour, $nmin, $nsec);
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetTimeZoneTitle_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
#-----------------------------------------------------------------------------
sub GetTimeZoneTitle_timezone {
	return ($PluginTimeZoneSeconds/3600);
}


1;	# Do not remove this line
