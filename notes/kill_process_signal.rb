require "net/http"
require 'uri'
require "pry"
#############################
staff_urls = %w(
https://www.google.com
http://www.lassenonline.com/MiscPage_13
http://www.hubertvesterhonda.com/staff.aspx
http://www.cjwilsonmazdaoflakevilla.com/dealership/staff.htm
http://www.chapmanfordlancaster.net/dealership/staff.htm
https://www.bentonnissanofhoover.com/staff
https://www.yahoo.com
https://ruby-doc.org
https://www.w3schools.com
http://example.com/index.html
)
#############################

def url_exist?(url_string)
  begin
    url = URI.parse(url_string)
    req = Net::HTTP.new(url.host, url.port)
    req.use_ssl = (url.scheme == 'https')
    res = req.request_head(url || '/')
    if res.kind_of?(Net::HTTPRedirection)
      url_exist?(res['location']) # Go after any redirect and make sure you can access the FWD URL
    else
      res.code[0] != "4" #false if http code starts with 4 - error on your side.
    end
  rescue
    # puts $!.message
    false #false if can't find the server
  end
end

###############################
class JobWorker
  def initialize(staff_url)
    @staff_url = staff_url
    @pid = 0
    @ppid = Process.pid
    puts "\n\n#{@staff_url} Parent: #{@ppid}"
  end

  def task
    fork do
      @pid = Process.pid
      puts "#{@staff_url} Fork: #{@pid}"

      url_sts = url_exist?(@staff_url)
      puts "#{url_sts}: #{@staff_url}"

    end
    Process.wait
  end
end

###
def process_starter(staff_urls)
  staff_urls.each do |staff_url|
    JobWorker.new(staff_url).task
  end
end

process_starter(staff_urls)
####################################


# https://www.google.com Parent: 79332
# https://www.google.com Fork: 79333
# true: https://www.google.com
#
#
# http://www.lassenonline.com/MiscPage_13 Parent: 79332
# http://www.lassenonline.com/MiscPage_13 Fork: 79334
# false: http://www.lassenonline.com/MiscPage_13
#
#
# http://www.hubertvesterhonda.com/staff.aspx Parent: 79332
# http://www.hubertvesterhonda.com/staff.aspx Fork: 79335
# true: http://www.hubertvesterhonda.com/staff.aspx
#
#
# http://www.cjwilsonmazdaoflakevilla.com/dealership/staff.htm Parent: 79332
# http://www.cjwilsonmazdaoflakevilla.com/dealership/staff.htm Fork: 79336
# true: http://www.cjwilsonmazdaoflakevilla.com/dealership/staff.htm
#
#
# http://www.chapmanfordlancaster.net/dealership/staff.htm Parent: 79332
# http://www.chapmanfordlancaster.net/dealership/staff.htm Fork: 79339
# true: http://www.chapmanfordlancaster.net/dealership/staff.htm
#
#
# https://www.bentonnissanofhoover.com/staff Parent: 79332
# https://www.bentonnissanofhoover.com/staff Fork: 79340
# true: https://www.bentonnissanofhoover.com/staff
#
#
# https://www.yahoo.com Parent: 79332
# https://www.yahoo.com Fork: 79342
# true: https://www.yahoo.com
#
#
# https://ruby-doc.org Parent: 79332
# https://ruby-doc.org Fork: 79343
# true: https://ruby-doc.org
#
#
# https://www.w3schools.com Parent: 79332
# https://www.w3schools.com Fork: 79344
# true: https://www.w3schools.com
