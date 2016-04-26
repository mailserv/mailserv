class Rrdmon
require 'date'
require 'tmpdir'
#require 'RRD'

  def initialize
    @rrd_dir     = "/var/spool/rrd"
    @orange      = "#EC9D48"
    @orange_bold = "#CC7016"
    @green       = "#54EC48"
    @green_bold  = "#24BC14"
    @red         = "#EA644A"
    @red_bold    = "#CC3118"
    @blue        = "#48C4EC"
    @blue_bold   = "#1598C3"
    @yellow      = "#ECD748"
    @yellow_bold = "#C9B215"
    @pink        = "#DE48EC"
    @pink_bold   = "#B415C7"
    @purple      = "#7648EC"
    @purple_bold = "#4D18E4"

    @nl = '\n'
    @lb = '\s'
  end

  def daily
    @start_time = -86400
    @poll_time = 288
    @output_dir = "#{RAILS_ROOT}/public/images/rrd/daily"
    %x{mkdir -p #{@output_dir}} unless File.exists?(@output_dir)
    
    self.cpu
    self.mem
    self.swap
    self.mail
  end

  def weekly
    @start_time = -86400*7
    @poll_time = 288*7
    @output_dir = "#{RAILS_ROOT}/public/images/rrd/weekly"
    %x{mkdir -p #{@output_dir}} unless File.exists?(@output_dir)
    
    self.cpu
    self.mem
    self.swap
    self.mail
  end

  def monthly
    @start_time = -86400*31
    @poll_time = 288*31
    @output_dir = "#{RAILS_ROOT}/public/images/rrd/monthly"
    %x{mkdir -p #{@output_dir}} unless File.exists?(@output_dir)
    
    self.cpu
    self.mem
    self.swap
    self.mail
  end

  def cpu  # ========================= CPU =========================

    cpu_rrd = "#{@rrd_dir}/cpu.rrd"
system <<-eos 
	/usr/local/bin/rrdtool graph "#{@output_dir}/cpu.png" \
	--start #{@start_time} --end -900 \
	--lazy --width=80 --height=80 \
	--imgformat PNG --upper-limit 100 \
	--lower-limit 0 --rigid --lazy \
	DEF:user=#{cpu_rrd}:user:AVERAGE \
	DEF:sys=#{cpu_rrd}:system:AVERAGE \
	DEF:idle=#{cpu_rrd}:idle:AVERAGE \
	CDEF:Ln1=user,user,UNKN,IF \
	CDEF:Ln2=sys,sys,UNKN,IF \
	CDEF:Ln3=sys,user,+ \
	AREA:user#{@yellow}: \
	STACK:sys#{@orange}: \
	STACK:idle#{@green}: \
	LINE1:Ln1#{@yellow_bold} \
	LINE1:Ln3#{@orange_bold}

eos
  
end


  def mem  # ========================= MEM =========================

    mem_rrd = "#{@rrd_dir}/mem.rrd"
     system <<-eos
	/usr/local/bin/rrdtool graph "#{@output_dir}/mem.png" \
	--start #{@start_time} --end -300 \
	--width=80 --height=80 \
	--imgformat PNG --lazy \
	--lower-limit 0 --upper-limit 100 \
	DEF:usage=#{mem_rrd}:usage:AVERAGE \
	DEF:free=#{mem_rrd}:free:AVERAGE \
	AREA:usage#{@orange}: \
	STACK:free#{@green}:
     eos
  end

  def swap  # ========================= SWAP =========================

    swap_rrd = "#{@rrd_dir}/swap.rrd"
     system <<-eos
	/usr/local/bin/rrdtool graph "#{@output_dir}/swap.png" \
	--start #{@start_time} \
	--end -300 --lazy \
	--width=80 --height=80 \
	--imgformat PNG \
	--lower-limit 0 \
	DEF:usage=#{swap_rrd}:usage:AVERAGE \
	DEF:free=#{swap_rrd}:free:AVERAGE \
	AREA:usage#{@orange} \
	STACK:free#{@green}
     eos
  end

  def mail  # ========================= MAIL =========================

    mail_rrd = "#{@rrd_dir}/mail.rrd"
     system <<-eos
	/usr/local/bin/rrdtool graph "#{@output_dir}/mail.png" \
	--start #{@start_time} --end -300 \
	--imgformat PNG \
	--lower-limit 0 --lazy \
	--width=260 --height=122 \
	DEF:sent=#{mail_rrd}:sent:AVERAGE \
	DEF:received=#{mail_rrd}:received:AVERAGE \
	"CDEF:sent_sum=sent,#{@poll_time},*" \
	"CDEF:received_sum=received,#{@poll_time},*" \
	"CDEF:sent_fixed=sent,300,*" \
	COMMENT:"#{@lb}" \
	COMMENT:"               Total    Avg      Max     Min    mails/s#{@nl}" \
	COMMENT:"#{@lb}" \
	AREA:sent#{@green}:"Sent     " \
	GPRINT:sent_sum:AVERAGE:%6.0lf \
	GPRINT:sent:AVERAGE:%6.2lf \
	GPRINT:sent:MAX:%6.2lf \
	GPRINT:sent:MIN:%6.2lf"#{@nl}" \
	LINE1:received#{@orange}:"Received " \
	GPRINT:received_sum:AVERAGE:%6.0lf \
	GPRINT:received:AVERAGE:%6.2lf \
	GPRINT:received:MAX:%6.2lf \
	GPRINT:received:MIN:%6.2lf"#{@nl}"
      eos


     mail_rrd = "#{@rrd_dir}/mail.rrd"
      system <<-eos
	/usr/local/bin/rrdtool graph #{@output_dir}/mail_block.png \
	--start #{@start_time} --end -300 \
	--imgformat PNG \
	--lower-limit 0 \
	--width=280 --height=100 --lazy \
	DEF:bounced=#{mail_rrd}:bounced:AVERAGE \
	DEF:rejected=#{mail_rrd}:rejected:AVERAGE \
	DEF:virus=#{mail_rrd}:virus:AVERAGE \
	DEF:spam=#{mail_rrd}:spam:AVERAGE \
	"CDEF:bounced_sum=bounced,#{@poll_time},*" \
	"CDEF:rejected_sum=rejected,#{@poll_time},*" \
	"CDEF:virus_sum=virus,#{@poll_time},*" \
	"CDEF:spam_sum=spam,#{@poll_time},*" \
	COMMENT:"#{@lb}" \
	COMMENT:"              Total      Avg       Max      Min#{@nl}" \
	AREA:rejected#{@purple}:"Rejected " \
	GPRINT:rejected_sum:AVERAGE:%6.0lf \
	GPRINT:rejected:AVERAGE:%7.2lf \
	GPRINT:rejected:MAX:%7.2lf \
	GPRINT:rejected:MIN:%7.2lf"#{@nl}" \
	AREA:bounced#{@red}:"Bounced  " \
	GPRINT:bounced_sum:AVERAGE:%6.0lf \
	GPRINT:bounced:AVERAGE:%7.2lf \
	GPRINT:bounced:MAX:%7.2lf \
	GPRINT:bounced:MIN:%7.2lf"#{@nl}" \
	LINE1:virus#{@blue}:"Virus    " \
	GPRINT:virus_sum:AVERAGE:%6.0lf \
	GPRINT:virus:AVERAGE:%7.2lf \
	GPRINT:virus:MAX:%7.2lf \
	GPRINT:virus:MIN:%7.2lf"#{@nl}" \
	LINE1:spam#{@orange}:"Spam     " \
	GPRINT:spam_sum:AVERAGE:%6.0lf \
	GPRINT:spam:AVERAGE:%7.2lf \
	GPRINT:spam:MAX:%7.2lf \
	GPRINT:spam:MIN:%7.2lf"#{@nl}"
      eos
    end 

end
