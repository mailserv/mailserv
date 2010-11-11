#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GeoIp_Isp_Maxmind AWStats plugin
# This plugin allow you to add a city report.
# Need the licensed ISP database from Maxmind.
#-----------------------------------------------------------------------------
# Perl Required Modules: Geo::IP (Geo::IP::PurePerl is not yet supported)
#-----------------------------------------------------------------------------
# $Revision: 1.5 $ - $Author: eldy $ - $Date: 2005/12/14 23:44:33 $


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
if (!eval ('require "Geo/IP.pm";')) 	{
    return $@?"Error: $@":"Error: Need Perl module Geo::IP (Geo::IP::PurePerl is not yet supported)";
}
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="6.2";
my $PluginHooksFunctions="AddHTMLMenuLink AddHTMLGraph ShowInfoHost SectionInitHashArray SectionProcessIp SectionProcessHostname SectionReadHistory SectionWriteHistory";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$geoip_isp_maxmind
%_isp_p
%_isp_h
%_isp_k
%_isp_l
$MAXNBOFSECTIONGIR
$MAXLENGTH
/;
# ----->


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_geoip_isp_maxmind {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
    $MAXNBOFSECTIONGIR=10;
    $MAXLENGTH=20;
    
	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin geoip_isp_maxmind: InitParams=$InitParams",1);
#    if ($UpdateStats) {
    	my ($mode,$datafile)=split(/\s+/,$InitParams,2);
    	if (! $datafile) { $datafile="GeoIPISP.dat"; }
    	if ($mode eq '' || $mode eq 'GEOIP_MEMORY_CACHE')  { $mode=Geo::IP::GEOIP_MEMORY_CACHE(); }
    	else { $mode=Geo::IP::GEOIP_STANDARD(); }
    	debug(" Plugin geoip_isp_maxmind: GeoIP initialized in mode $mode",1);
        $geoip_isp_maxmind = Geo::IP->open($datafile, $mode);
#    }
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLMenuLink_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLMenuLink_geoip_isp_maxmind {
    my $categ=$_[0];
    my $menu=$_[1];
    my $menulink=$_[2];
    my $menutext=$_[3];
	# <-----
	if ($Debug) { debug(" Plugin geoip_isp_maxmind: AddHTMLMenuLink"); }
    if ($categ eq 'who') {
        $menu->{'plugin_geoip_isp_maxmind'}=0.6;              # Pos
        $menulink->{'plugin_geoip_isp_maxmind'}=2;          # Type of link
        $menutext->{'plugin_geoip_isp_maxmind'}="ISP";      # Text
    }
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLGraph_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLGraph_geoip_isp_maxmind {
    my $categ=$_[0];
    my $menu=$_[1];
    my $menulink=$_[2];
    my $menutext=$_[3];
	# <-----
    my $ShowISP='H';
	$MinHit{'Isp'}=1;
	my $total_p; my $total_h; my $total_k;
	my $rest_p; my $rest_h; my $rest_k;

	if ($Debug) { debug(" Plugin geoip_isp_maxmind: AddHTMLGraph $categ $menu $menulink $menutext"); }
	my $title='ISP';
	&tab_head("$title",19,0,'isp');
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>ISP : ".((scalar keys %_isp_h)-($_isp_h{'unknown'}?1:0))."</th>";
	if ($ShowISP =~ /P/i) { print "<th bgcolor=\"#$color_p\" width=\"80\">$Message[56]</th>"; }
	if ($ShowISP =~ /P/i) { print "<th bgcolor=\"#$color_p\" width=\"80\">$Message[15]</th>"; }
	if ($ShowISP =~ /H/i) { print "<th bgcolor=\"#$color_h\" width=\"80\">$Message[57]</th>"; }
	if ($ShowISP =~ /H/i) { print "<th bgcolor=\"#$color_h\" width=\"80\">$Message[15]</th>"; }
	if ($ShowISP =~ /B/i) { print "<th bgcolor=\"#$color_k\" width=\"80\">$Message[75]</th>"; }
	if ($ShowISP =~ /L/i) { print "<th width=\"120\">$Message[9]</th>"; }
	print "</tr>\n";
	$total_p=$total_h=$total_k=0;
	my $count=0;
	&BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Isp'},\%_isp_h,\%_isp_h);
    	foreach my $key (@keylist) {
            if ($key eq 'unknown') { next; }
   			my $p_p; my $p_h;
   			if ($TotalPages) { $p_p=int($_isp_p{$key}/$TotalPages*1000)/10; }
   			if ($TotalHits)  { $p_h=int($_isp_h{$key}/$TotalHits*1000)/10; }
   		    print "<tr>";
   		    my $isp=$key; $isp =~ s/_/ /g;
   		    print "<td class=\"aws\">".ucfirst($isp)."</td>";
    		if ($ShowISP =~ /P/i) { print "<td>".($_isp_p{$key}?$_isp_p{$key}:"&nbsp;")."</td>"; }
    		if ($ShowISP =~ /P/i) { print "<td>".($_isp_p{$key}?"$p_p %":'&nbsp;')."</td>"; }
    		if ($ShowISP =~ /H/i) { print "<td>".($_isp_h{$key}?$_isp_h{$key}:"&nbsp;")."</td>"; }
    		if ($ShowISP =~ /H/i) { print "<td>".($_isp_h{$key}?"$p_h %":'&nbsp;')."</td>"; }
    		if ($ShowISP =~ /B/i) { print "<td>".Format_Bytes($_isp_k{$key})."</td>"; }
    		if ($ShowISP =~ /L/i) { print "<td>".($_isp_p{$key}?Format_Date($_isp_l{$key},1):'-')."</td>"; }
    		print "</tr>\n";
    		$total_p += $_isp_p{$key}||0;
    		$total_h += $_isp_h{$key};
    		$total_k += $_isp_k{$key}||0;
    		$count++;
    	}
	if ($Debug) { debug("Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h",2); }
	$rest_p=0;
	$rest_h=$TotalHits-$total_h;
	$rest_k=0;
	if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other cities
#	    print "<tr>";
#	    print "<td class=\"aws\">&nbsp;</td>";
#   		if ($ShowISP =~ /P/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowISP =~ /P/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowISP =~ /H/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowISP =~ /H/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowISP =~ /B/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowISP =~ /L/i) { print "<td>&nbsp;</td>"; }
#        print "</tr>\n";

		my $p_p; my $p_h;
		if ($TotalPages) { $p_p=int($rest_p/$TotalPages*1000)/10; }
		if ($TotalHits)  { $p_h=int($rest_h/$TotalHits*1000)/10; }
		print "<tr>";
		print "<td class=\"aws\"><span style=\"color: #$color_other\">$Message[2]/$Message[0]</span></td>";
		if ($ShowISP =~ /P/i) { print "<td>".($rest_p?$rest_p:"&nbsp;")."</td>"; }
   		if ($ShowISP =~ /P/i) { print "<td>".($rest_p?"$p_p %":'&nbsp;')."</td>"; }
		if ($ShowISP =~ /H/i) { print "<td>".($rest_h?$rest_h:"&nbsp;")."</td>"; }
   		if ($ShowISP =~ /H/i) { print "<td>".($rest_h?"$p_h %":'&nbsp;')."</td>"; }
		if ($ShowISP =~ /B/i) { print "<td>".Format_Bytes($rest_k)."</td>"; }
		if ($ShowISP =~ /L/i) { print "<td>&nbsp;</td>"; }
		print "</tr>\n";
	}
	&tab_end();

	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowInfoHost_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to add additionnal columns to the Hosts report.
# This function is called when building rows of the report (One call for each
# row). So it allows you to add a column in report, for example with code :
#   print "<TD>This is a new cell for $param</TD>";
# Parameters: Host name or ip
#-----------------------------------------------------------------------------
sub ShowInfoHost_geoip_isp_maxmind {
    my $param="$_[0]";
	# <-----
	if ($param eq '__title__') {
    	my $NewLinkParams=${QueryString};
    	$NewLinkParams =~ s/(^|&|&amp;)update(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&|&amp;)output(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&|&amp;)staticlinks(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&|&amp;)framename=[^&]*//i;
    	my $NewLinkTarget='';
    	if ($DetailedReportsOnNewWindows) { $NewLinkTarget=" target=\"awstatsbis\""; }
    	if (($FrameName eq 'mainleft' || $FrameName eq 'mainright') && $DetailedReportsOnNewWindows < 2) {
    		$NewLinkParams.="&framename=mainright";
    		$NewLinkTarget=" target=\"mainright\"";
    	}
    	$NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
    	$NewLinkParams =~ s/^&amp;//; $NewLinkParams =~ s/&amp;$//;
    	if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }

		print "<th width=\"80\">";
        print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?XMLEncode("$AWScript?${NewLinkParams}output=plugin_geoip_isp_maxmind"):"$PROG$StaticLinks.plugin_geoip_isp_maxmind.$StaticExt")."\"$NewLinkTarget>GeoIP<br>ISP</a>";
        print "</th>";
	}
	elsif ($param) {
        my $ip=0;
		my $key;
		if ($param =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {	# IPv4 address
		    $ip=4;
			$key=$param;
		}
		elsif ($param =~ /^[0-9A-F]*:/i) {						# IPv6 address
		    $ip=6;
			$key=$param;
		}
		print "<td>";
		if ($key && $ip==4) {
        	my $isp=$geoip_isp_maxmind->org_by_addr($param) if $geoip_isp_maxmind;
        	if ($Debug) { debug("  Plugin geoip_isp_maxmind: GetIspByIp for $param: [$isp]",5); }
		    if ($isp) {
		        if (length($isp) <= $MAXLENGTH) {
		            print "$isp";
		        }
		        else {
		            print substr($isp,0,$MAXLENGTH).'...';
		        }
		    }
		    else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
		}
		if ($key && $ip==6) {
		    print "<span style=\"color: #$color_other\">$Message[0]</span>";
		}
		if (! $key) {
        	my $isp=$geoip_isp_maxmind->org_by_name($param) if $geoip_isp_maxmind;
        	if ($Debug) { debug("  Plugin geoip_isp_maxmind: GetIspByHostname for $param: [$isp]",5); }
		    if ($isp) {
		        if (length($isp) <= $MAXLENGTH) {
		            print "$isp";
		        }
		        else {
		            print substr($isp,0,$MAXLENGTH).'...';
		        }
		    }
		    else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
		}
		print "</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	return 1;
	# ----->
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionInitHashArray_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionInitHashArray_geoip_isp_maxmind {
    my $param="$_[0]";
	# <-----
	if ($Debug) { debug(" Plugin geoip_isp_maxmind: Init_HashArray"); }
	%_isp_p = %_isp_h = %_isp_k = %_isp_l =();
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessIP_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessIp_geoip_isp_maxmind {
    my $param="$_[0]";      # Param must be an IP
	# <-----
	my $isp = $geoip_isp_maxmind->org_by_addr($param) if $geoip_isp_maxmind;
	if ($Debug) { debug("  Plugin geoip_isp_maxmind: GetIspByIp for $param: [$isp]",5); }
    if ($isp) {
        $isp =~ s/\s/_/g;
        $_isp_h{$isp}++;
    } else {
        $_isp_h{'unknown'}++;
    }
#	if ($timerecord > $_isp_l{$city}) { $_isp_l{$city}=$timerecord; }
	# ----->
	return;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessHostname_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessHostname_geoip_isp_maxmind {
    my $param="$_[0]";      # Param must be an IP
	# <-----
	my $isp = $geoip_isp_maxmind->org_by_name($param) if $geoip_isp_maxmind;
	if ($Debug) { debug("  Plugin geoip_isp_maxmind: GetIspByHostname for $param: [$isp]",5); }
    if ($isp) {
        $isp =~ s/\s/_/g;
        $_isp_h{$isp}++;
    } else {
        $_isp_h{'unknown'}++;
    }
#	if ($timerecord > $_isp_l{$city}) { $_isp_l{$city}=$timerecord; }
	# ----->
	return;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionReadHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionReadHistory_geoip_isp_maxmind {
    my $issectiontoload=shift;
    my $xmlold=shift;
    my $xmleb=shift;
	my $countlines=shift;
	# <-----
	if ($Debug) { debug(" Plugin geoip_isp_maxmind: Begin of PLUGIN_geoip_isp_maxmind section"); }
	my @field=();
	my $count=0;my $countloaded=0;
	do {
		if ($field[0]) {
			$count++;
			if ($issectiontoload) {
				$countloaded++;
				if ($field[2]) { $_isp_h{$field[0]}+=$field[2]; }
			}
		}
		$_=<HISTORY>;
		chomp $_; s/\r//;
		@field=split(/\s+/,($xmlold?CleanFromTags($_):$_));
		$countlines++;
	}
	until ($field[0] eq 'END_PLUGIN_geoip_isp_maxmind' || $field[0] eq "${xmleb}END_PLUGIN_geoip_isp_maxmind" || ! $_);
	if ($field[0] ne 'END_PLUGIN_geoip_isp_maxmind' && $field[0] ne "${xmleb}END_PLUGIN_geoip_isp_maxmind") { error("History file is corrupted (End of section PLUGIN not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).","","",1); }
	if ($Debug) { debug(" Plugin geoip_isp_maxmind: End of PLUGIN_geoip_isp_maxmind section ($count entries, $countloaded loaded)"); }
	# ----->
	return 0;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionWriteHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionWriteHistory_geoip_isp_maxmind {
    my ($xml,$xmlbb,$xmlbs,$xmlbe,$xmlrb,$xmlrs,$xmlre,$xmleb,$xmlee)=(shift,shift,shift,shift,shift,shift,shift,shift,shift);
    if ($Debug) { debug(" Plugin geoip_isp_maxmind: SectionWriteHistory_geoip_isp_maxmind start - ".(scalar keys %_isp_h)); }
	# <-----
	print HISTORYTMP "\n";
	if ($xml) { print HISTORYTMP "<section id='plugin_geoip_isp_maxmind'><sortfor>$MAXNBOFSECTIONGIR</sortfor><comment>\n"; }
	print HISTORYTMP "# Plugin key - Pages - Hits - Bandwidth - Last access\n";
	#print HISTORYTMP "# The $MaxNbOfExtra[$extranum] first number of hits are first\n";
	$ValueInFile{'plugin_geoip_isp_maxmind'}=tell HISTORYTMP;
	print HISTORYTMP "${xmlbb}BEGIN_PLUGIN_geoip_isp_maxmind${xmlbs}".(scalar keys %_isp_h)."${xmlbe}\n";
	&BuildKeyList($MAXNBOFSECTIONGIR,1,\%_isp_h,\%_isp_h);
	my %keysinkeylist=();
	foreach (@keylist) {
		$keysinkeylist{$_}=1;
		#my $page=$_isp_p{$_}||0;
		#my $bytes=$_isp_k{$_}||0;
		#my $lastaccess=$_isp_l{$_}||'';
		print HISTORYTMP "${xmlrb}$_${xmlrs}0${xmlrs}", $_isp_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	foreach (keys %_isp_h) {
		if ($keysinkeylist{$_}) { next; }
		#my $page=$_isp_p{$_}||0;
		#my $bytes=$_isp_k{$_}||0;
		#my $lastaccess=$_isp_l{$_}||'';
		print HISTORYTMP "${xmlrb}$_${xmlrs}0${xmlrs}", $_isp_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	print HISTORYTMP "${xmleb}END_PLUGIN_geoip_isp_maxmind${xmlee}\n";
	# ----->
	return 0;
}



1;	# Do not remove this line
