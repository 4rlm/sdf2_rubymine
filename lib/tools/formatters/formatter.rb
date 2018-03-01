# require 'open-uri'
# require 'mechanize'
# require 'uri'
# require 'nokogiri'
# require 'socket'
# require 'httparty'
# require 'delayed_job'
# require 'curb' #=> for curler

# %w{open-uri mechanize uri nokogiri socket httparty delayed_job curb}.each { |x| require x }
# require 'format_adr'
# require 'format_act'
# require 'format_phone'
# require 'format_web'
%w{format_adr format_act cross_ref format_phone format_web}.each { |x| require x }


## CLASS METHOD TO START, EXPLAIN, OR TEST OTHER FORMATTER CLASSES AND METHODS.
class Formatter
  include FormatAct
  include FormatAdr
  include CrossRef
  include FormatPhone
  include FormatWeb

  # def initialize
  #   @format_act = FormatAct
  #   @format_adr = FormatAdr
  #   @cross_ref = CrossRef
  #   @format_phone = FormatPhone
  #   @format_web = FormatWeb
  # end

  #######################################
  #CALL: ActScraper.new.start_act_scraper
  #######################################

  def remove_invalids(act_name, invalid_list)
    if act_name && invalid_list
      sngl_invals = []
      dbl_invals = []
      invals = []

      ##### DBL Part - Start ####
      invalid_list.each do |inval|
        inval_parts_length = inval.split(' ').length
        if inval_parts_length > 1 && act_name.downcase.include?(inval.downcase)
          dbl_invals << inval
        end
      end
      dbl_invals.each { |inval| act_name = act_name.gsub(inval, '') }
      ##### DBL Part - End ####

      ##### SNGL Part - Start ####
      act_name&.split(' ')&.select do |part|
        formatted_part = part.tr('^A-Za-z0-9', '')&.downcase
        inval = invalid_list.find { |inval| formatted_part == inval.downcase }
        sngl_invals << part if inval.present?
      end
      act_name = (act_name.split(' ') - sngl_invals).join(' ')
      ##### SNGL Part - End ####

      invals += sngl_invals += dbl_invals
      found = invals&.first
      inval_hsh = {invals: invals, found: found, act_name: act_name}

      return inval_hsh
    end
  end


  def remove_phones_from_text(text)
    phones = []
    text.split(' ')&.each do |text_part|
      reg = Regexp.new("[(]?[0-9]{3}[ ]?[)-.]?[ ]?[0-9]{3}[ ]?[-. ][ ]?[0-9]{4}")
      text_part = nil if text_part.first == "0" || text_part.include?("(0") || !reg.match(text_part)
      phones << text_part if text_part
    end
    phones.each { |phone| text = text.gsub(phone, '') }

    return text
  end



  ### CONSIDER DELETING Some of BELOW - DON'T THINK ALL BEING USED #####

  #Call: Formatter.new.run_all_formatters
  def run_all_formatters
    format_webs
    format_adrs
    format_phones
  end


  #Call: Formatter.new.format_webs
  def format_webs
    # web_ids = Web.all.order("updated_at ASC").pluck(:id)
    # web_ids = Web.where.not(staff_page: nil).order("updated_at ASC").pluck(:id)
    web_ids = Web.all.order("updated_at ASC").pluck(:id)

    web_ids.each do |id|
      web_obj = Web.find(id)
      migrate_web_and_links(web_obj) # via FormatWeb
    end

  end


  #CALL: Formatter.new.format_adrs
  def format_adrs
    # Adr.where.not(full_adr: nil).in_batches.each do |each_batch|
    # Adr.in_batches.each do |each_batch|
    adr_ids = Adr.all.order("updated_at ASC").pluck(:id)
    adr_ids.each do |id|
      adr_obj = Adr.find(id)
      current_zip = adr_obj.zip
      new_zip = FormatAdr.format_zip(current_zip)
      adr_obj.update(zip: new_zip) if current_zip != new_zip

      update_hsh = {}
      current_full_adr = adr_obj.full_adr
      current_pin = adr_obj.pin

      new_full_adr = FormatAdr.generate_full_adr(adr_obj)
      update_hsh[:full_adr] = new_full_adr if current_full_adr != new_full_adr
      new_pin = FormatAdr.generate_pin(adr_obj.street, adr_obj.zip)
      update_hsh[:pin] = new_pin if current_pin != new_pin
      !update_hsh.empty? ? adr_obj.update(update_hsh) : adr_obj.touch
    end
  end


  #Call: Formatter.new.format_phones
  def format_phones
    phone_ids = Phone.where.not(phone: nil).order("updated_at ASC").pluck(:id)
    phone_ids.each do |id|
      phone_obj = Phone.find(id)
      phone = phone_obj.phone

      if phone.present?
        valid_phone = FormatPhone.validate_phone(phone)

        if valid_phone.nil?
          phone_obj.destroy
        elsif valid_phone && valid_phone != phone
          phone_obj.update(phone: valid_phone)
        else
          phone_obj.touch
        end

      end
    end
  end


  #Call: Mig.new.migrate_uni_acts

  #CALL: Formatter.new.letter_case_check(street)
  def letter_case_check(str)
    if str.present?
      flashes = str&.gsub(/[^ A-Za-z]/, '')&.strip&.split(' ')
      flash = flashes&.reject {|e| e.length < 3 }.join(' ')

      if flash.present?
        has_caps = flash.scan(/[A-Z]/).any?
        has_lows = flash.scan(/[a-z]/).any?
        if !has_caps || !has_lows
          str = str.split(' ')&.each { |el| el.capitalize! if el.gsub(/[^ A-Za-z]/, '')&.strip&.length > 2 }&.join(' ')
        end
      end
      return str
    end
  end


  #CALL: Formatter.new.check_conjunctions(str)
  def check_conjunctions(str)
    if str.present?
      commons = %w(a an and as by in of out to with)
      str_parts = str.split(' ')
      str_parts.map do |str_part|
        if str_part.scan(/[a-zA-Z]/).any?
          commons.each do |common|
            if str_part.downcase == common
              str_parts = str_parts&.join(' ')&.gsub(str_part, common)&.split(' ')
            end
          end
        end
      end
      str = str_parts.join(' ')
      return str
    end
  end



end
