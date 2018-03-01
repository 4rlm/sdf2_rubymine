require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'whois'
require 'delayed_job'
require 'timeout'
require 'net/ping'


class CheckInt

  #CALL: CheckInt.new.check_int
  def check_int
    connection = false

    if !test_internet_connection
      ping_attempt_limit = 1
      ping_attempt_count = 1
      sleep_time = 5

      while !connection
        # sleep_time * ping_attempt_count
        sleep_time *= ping_attempt_count
        ping_attempt_count += 1
        puts "Waiting #{sleep_time} for ping attempt #{ping_attempt_count}"
        sleep(sleep_time)

        connection = test_internet_connection
        break if connection

        if ping_attempt_count >= ping_attempt_limit
          # puts "Force Quit: #{ping_attempt_limit} pings | #{sleep_time} seconds"
          connection = false
          return
          # return connection ## See if this works.  Would be lightest option.
          # Process.kill("WINCH", Process.pid)  #=> quits class.
          # Process.kill(28)
          # Process.kill(9, Process.ppid) #=> Too Strong: kills rails server.
        end

      end
      check_int
    else
      connection = true
    end

    return connection
  end


  def test_internet_connection
    sample_url = ping_url
    puts "PING: #{sample_url}"

    begin
      result = true if open(sample_url)
    rescue
      result = false
    end

    return result
  end


  def ping_url
    pingable_urls = %w(
    http://speedtest.hafslundtelekom.net/
    http://www.whatsmyip.org/
    https://fast.com/
    https://www.cox.com/
    http://speedtest.xfinity.com/
    https://www.iplocation.net/
    http://www.bandwidthplace.com/
    http://www.speedinternet.co/
    http://www.centurylink.com/
    https://frontier.com/
    https://www.windstream.com/
    https://www.rcn.com/
    http://atlanticbb.com/
    http://mygrande.com/
    https://speedof.me/
    https://www.lifewire.com/
    https://www.cnet.com/
    https://www.megapath.com/
    https://www.consolidated.com/
    http://www.merck.com/
    https://www.pfizer.com/
    https://www.gsk.com/
    https://www.jnj.com/
    https://www.johnsonsbaby.com/
    https://www.discovernursing.com/
    https://www.cancer.org/
    https://www.verizon.com/)

    return pingable_urls.sample
  end


end
