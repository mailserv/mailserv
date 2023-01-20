#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

# --------------------------------------------------------------
# /etc/awstats
# --------------------------------------------------------------
mkdir /etc/awstats

basedir="/usr/local"
mkdir -p $basedir

echo "Getting latest AWStats version"
# aw_file=`lynx -dump -listonly http://sourceforge.net/projects/awstats/files/AWStats/ | egrep "([0-9\.]\/)" | head -1 | awk '{print $2}' | xargs lynx -dump | egrep "(awstats-[0-9\.]+\.tar\.gz\/download)" | head -1 | awk '{ print $2 }'`.strip
aw_file="https://sourceforge.net/projects/awstats/files/AWStats/7.8/awstats-7.8.tar.gz/download"

# rc_dir = "/var/www/webmail/" + aw_file.match(/(awstats-[\d\.]+)\.(tar|zip)/)[1]

# # make sure we're downloading the tar.gz file
# aw_file.gsub!(/\.zip/, ".tar.gz")

echo "Downloading AWStats version " 
# + aw_file.match(/([\d\.]+)\.(tar|zip)/)[1].to_s
ftp -Vmo - $aw_file | tar -zxf - -C $basedir -s /awstats-[0-9\.]*/awstats/
echo "done"
