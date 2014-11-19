#!/usr/local/bin/ruby
#require "RRD"
#ruby RRD has been disabled
require 'rubygems'
require 'date'


rrd_dir = "/var/spool/rrd"
start = Time.now.to_i - 1

# Make sure that the rrd_dir exists
%x{mkdir -p #{rrd_dir}} unless File.directory?(rrd_dir)


# Accept data every 5 minutes
# Store 1 datapoint every 5 minute and keep 1 day
# Store 1 datapoint every 30 minutes and keep 1 week
# Store 1 datapoint every 2 hours and keep 1 month
# Store 1 datapoint every 1 day and keep 1 year
cpu_rrd = "#{rrd_dir}/cpu.rrd"
unless File.exists?(cpu_rrd)
system <<-eos
rrdtool create #{cpu_rrd} \
--start #{start} \
--step 300 \
DS:user:GAUGE:400:0:100 \
DS:system:GAUGE:400:0:100 \
DS:idle:GAUGE:400:0:100 \
RRA:AVERAGE:0.5:1:288 \
RRA:AVERAGE:0.5:6:336 \
RRA:AVERAGE:0.5:24:372 \
RRA:AVERAGE:0.5:288:365
eos
end

# Accept data every 5 minutes
# Store 1 datapoint every 5 minute and keep 1 day
# Store 1 datapoint every 30 minutes and keep 1 week
# Store 1 datapoint every 2 hours and keep 1 month
# Store 1 datapoint every 1 day and keep 1 year
mem_rrd = "#{rrd_dir}/mem.rrd"
unless File.exists?(mem_rrd)
system <<-eos
rrdtool create #{mem_rrd} \
--start #{start} \
--step 300 \
DS:usage:GAUGE:400:0:U \
DS:free:GAUGE:400:0:U \
RRA:AVERAGE:0.5:1:288 \
RRA:AVERAGE:0.5:6:336 \
RRA:AVERAGE:0.5:24:372 \
RRA:AVERAGE:0.5:288:365
eos
end


# Accept data every 5 minutes
# Store 1 datapoint every 5 minute and keep 1 day
# Store 1 datapoint every 30 minutes and keep 1 week
# Store 1 datapoint every 2 hours and keep 1 month
# Store 1 datapoint every 1 day and keep 1 year
swap_rrd = "#{rrd_dir}/swap.rrd"
unless File.exists?(swap_rrd)
system <<-eos 
rrdtool create #{swap_rrd} \
--start #{start} \
--step 300 \
DS:usage:GAUGE:400:0:U \
DS:free:GAUGE:400:0:U \
RRA:AVERAGE:0.5:1:288 \
RRA:AVERAGE:0.5:6:336 \
RRA:AVERAGE:0.5:24:372 \
RRA:AVERAGE:0.5:288:365
eos
end


# Accept data every 5 minutes
# Store 1 datapoint every 5 minute and keep 1 day
# Store 1 datapoint every 30 minutes and keep 1 week
# Store 1 datapoint every 2 hours and keep 1 month
# Store 1 datapoint every 1 day and keep 1 year
mail_rrd = "#{rrd_dir}/mail.rrd"
unless File.exists?(mail_rrd)
system <<-eos 
rrdtool create #{mail_rrd} \
--start #{start} \
--step 300 \
DS:sent:GAUGE:400:0:U \
DS:received:GAUGE:400:0:U \
DS:bounced:GAUGE:400:0:U \
DS:rejected:GAUGE:400:0:U \
DS:virus:GAUGE:400:0:U \
DS:spam:GAUGE:400:0:U \
RRA:AVERAGE:0.5:1:288 \
RRA:AVERAGE:0.5:6:336 \
RRA:AVERAGE:0.5:24:372 \
RRA:AVERAGE:0.5:288:365
eos
end
