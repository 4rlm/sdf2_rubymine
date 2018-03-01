# # class RtsManager # Update database with the result of RoofTop Scraper
# class AsManager # Update database with the result of RoofTop Scraper
#   # include FormatPhone
#
#   def initialize
#     @formatter = Formatter.new
#   end
#
#
#   # STRIPS AND FORMATS DATA BEFORE SAVING TO DB
#   def address_formatter(org, street, city, state, zip, phone, as_phones)
#     binding.pry
#
#     org = nil if org.blank?
#     street = nil if street.blank?
#     city = nil if city.blank?
#     state = nil if state.blank?
#     zip = nil if zip.blank?
#     phone = nil if phone.blank?
#
#     org.strip! if org
#     street.strip! if street
#     city.strip! if city
#     state.strip! if state
#     zip.strip! if zip
#
#     if zip && state && zip.length < 5 && state > 2
#       temp_zip = state
#       temp_state = zip
#       zip = temp_zip
#       state = temp_state
#     end
#
#     full_addr_street = "#{street}, " if street
#     full_addr_city = "#{city}, " if city
#     full_addr_state = "#{state}, " if state
#     full_addr_zip = "#{zip}" if zip
#     full_addr = "#{full_addr_street}#{full_addr_city}#{full_addr_state}#{full_addr_zip}"
#     full_addr.strip!
#
#     if full_addr && full_addr[-1] == ","
#       full_addr = full_addr[0...-1]
#       full_addr.strip!
#     end
#
#     if full_addr && full_addr[0] == ","
#       full_addr = full_addr[1..-1]
#       full_addr.strip!
#     end
#
#     full_addr = nil if full_addr.blank?  || full_addr == ","
#
#     results_processor(org, street, city, state, zip, phone, as_phones, full_addr, web_obj)
#
#     as_hsh = {org, street, city, state, zip, phone, as_phones, full_addr}
#
#     # results_processor(org, street, city, state, zip, phone, as_phones, full_addr, web_obj)
#   end
#
#   # def results_processor(org, street, city, state, zip, phone, as_phones, full_addr, web_obj)
#   #   binding.pry
#   #
#   #   phone = format_phone(phone) if phone
#   #   phones = clean_phones_arr(as_phones)
#   #
#   #   if org || street || city || state || zip || phone || full_addr
#   #     # web_obj.update(indexer_status: "AccountScraper", acct_name: org, rt_sts: "AS Result", full_addr: full_addr, street: street, city: city, state: state, zip: zip, phone: phone, phones: phones, account_scrape_date: DateTime.now)
#   #   else
#   #     # web_obj.update(indexer_status: "AccountScraper", acct_name: org, rt_sts: "AS No-Result", account_scrape_date: DateTime.now)
#   #   end
#   # end
#
#
#   # ================== Helper ==================
#   def as_phones_finder(noko_page)
#     raw_data_1 = noko_page.at_css('body').inner_html
#     raw_data_2 = noko_page.at_css('body').text
#     reg = Regexp.new("[(]?[0-9]{3}[ ]?[)-.]?[ ]?[0-9]{3}[ ]?[-. ][ ]?[0-9]{4}")
#     Invalid = Regexp.new("[0-9]{5,}")
#     data_1 = raw_data_1.scan(reg)
#     data_2 = raw_data_2.scan(reg)
#     phones = data_1.uniq + data_2.uniq
#     phones = phones.uniq.sort
#     phones = phones.reject { |x| Invalid.match(x) }
#     phones = phones.map { |phone| @formatter.validate_phone(phone) }
#     return phones
#   end
#
# end
