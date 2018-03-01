class AsHelper # RoofTop Scraper Helper Method
  # include FormatPhone
  # PARSES OUT THE ADDRESS FROM:  noko_page.at_css('.dealer-info').text when address contains "\n"

  def initialize
    @formatter = Formatter.new
  end


  def as_phones_finder(noko_page)
    raw_data_1 = noko_page.at_css('body').inner_html
    raw_data_2 = noko_page.at_css('body').text
    reg = Regexp.new("[(]?[0-9]{3}[ ]?[)-.]?[ ]?[0-9]{3}[ ]?[-. ][ ]?[0-9]{4}")
    Invalid = Regexp.new("[0-9]{5,}")

    begin
      # raw_data_1 = utf_cleaner(raw_data_1)
      # raw_data_2 = utf_cleaner(raw_data_2)
      data_1 = raw_data_1&.scan(reg)
      data_2 = raw_data_2&.scan(reg)
      phones = data_1&.uniq + data_2&.uniq
      phones = phones&.uniq&.sort
      phones = phones&.reject { |x| Invalid.match(x) }
    rescue
      puts "PHONE RESCUE!!!"
      # phones = nil
      # return phones
    end

    phones = phones&.map { |phone| @formatter.validate_phone(phone) if phone.present? } if phones.present?
    return phones
  end

  def utf_cleaner(string)
    if string.present?
      string = string&.gsub(/\s/, ' ')&.strip ## Removes carriage returns and new lines.
      string = force_utf_encoding(string) ## Removes non-utf8 chars.
      return string
    end
  end


  def addr_parser(str)
    str.strip!
    parts = str.split("   ")
    parts.each do |s|
      if s == "" || s == "\n"
        parts.delete(s)
      else
        s.strip!
      end
    end

    for x in ["\n", ""]
      parts.delete(x) if parts.include?(x)
    end
    parts # returns array
  end

  # Parse full address into org, street, city, state, zip, phone.
  def addr_processor(full_addr)
    states, zips, phones = [], [], []

    if !full_addr.blank?
      addr_arr = asvalidator(full_addr)
      unless addr_arr.blank?
        # Sends Each Result Item to Check for Phone, State and Zip
        addr_arr.each do |item|
          phones << item if !item.blank?
          # state_zip = state_zip_get(item) if !state_zip_get(item).blank? # not working

          # if state_zip # not working
          #     states << state_zip[0..1] if !state_zip[0..1].blank? ## state
          #     zips << state_zip[-5..-1] if !state_zip[-5..-1].blank? ## zip
          # end

          if item.include?(" ") && item.split(" ").length == 2
            splits = item.split(" ")
            states.concat(splits)
            zips.concat(splits)
          else
            states << item
            zips << item
          end
        end
        street = addr_arr[0]
        city = addr_arr[1]
      end
    end
    {street: street, city: city, states: states, zips: zips, phones: phones}
  end

  # Helper method for `addr_processor(full_addr)` and `org_processor(orgs)`
  # Removes "\t", "\n"... from objects.
  def asvalidator(obj)
    objs = []
    unless obj.blank?
      obj = filter(obj, "\n")
      obj = filter(obj, "|")
      obj = filter(obj, "\t")
      obj = filter(obj, ",")

      # Separate address. eg. Nice Rd.CityName
      regex = Regexp.new("[a-z][\.]?[A-Z][a-z]")
      if regex.match(obj)
        obj = obj.gsub(/([a-z])[.]?([A-Z][a-z])/,'\1,\2')
      end

      objs = obj.split(",")

      negs = ["hours", "contact", "location", "map", "info", "directions", "used", "click", "proudly", "serves", "twitter", "geoplaces", "youtube", "facebook", "privacy", "choices", "window", "event", "listener", "contact", "function", "department", "featured", "vehicle", "customer", "today"]
      negs.each do |neg|
        objs.delete_if { |x| x.downcase.include?(neg) }
      end

      objs.map!{|obj| obj.strip}
      objs.delete_if {|x| x.blank?}
      objs = objs.uniq
    end
    objs
  end

  def org_processor(orgs)
    result = []
    orgs.each do |org|
      result.concat(asvalidator(org))
    end
    result
  end

  def org_addr_divider(org_n_addr)
    return {} if org_n_addr.nil?
    splits = org_n_addr.split("\n")
    parts = splits.map(&:strip).delete_if {|x| x.blank?}

    {org: parts.delete_at(0), addr: parts.join(',')}
  end

  def addr_ph_divider(addr_n_ph)
    return {} if addr_n_ph.nil?
    splits = addr_n_ph.split("\n")
    splits.map(&:strip).delete_if {|x| x.blank?}
  end

  def city_state_zip_divider(city_state_zip)
    return {} if city_state_zip.nil?
    splits = city_state_zip.split(",")
    city = splits.delete_at(0)
    st_zip = splits.first.strip.split(" ")

    {city: city, state: st_zip[0], zip: st_zip[1]}
  end

  # Validate org, street, city, state, zip, phone individually.
  def final_arr_qualifier(array, option)
    return if array.empty?
    negs = ["contact", "link", "click", "map", "(", "location", "savings"]
    result = nil

    array.each do |el|
      if !el.blank?
        result = org_qualifier(el, negs) if option == "org"
        result = street_qualifier(el, negs) if option == "street"
        result = city_qualifier(el, negs) if option == "city"
        result = state_qualifier(el, negs) if option == "state"
        result = zip_qualifier(el, negs) if option == "zip"
        # result = format_phone(el) if option == "phone" #=> via FormatPhone
        break if result
      end
    end
    result
  end

  # Helper method for `final_arr_qualifier(array, option)`
  def org_qualifier(org, negs)
    return if org.nil?
    alpha = org.tr('^A-Za-z', '')
    digits = org.tr('^0-9', '')
    smash = alpha+digits
    selected = negs.select {|neg| org.downcase.include?(neg) }

    (alpha == '' || alpha.length < 6) || (smash.length == 7 && digits.length == 5) || (selected.any?) ? nil : org
  end

  def street_qualifier(street, negs)
    return if street.nil?
    alpha = street.tr('^A-Za-z', '')
    digits = street.tr('^0-9', '')
    selected = negs.select {|neg| street.downcase.include?(neg) }
    (digits == '' || alpha == '' || (alpha.length == 2 && alpha != "US") ) || (selected.any?) ? nil : street
  end

  def city_qualifier(city, negs)
    return if city.nil?
    alpha = city.tr('^A-Za-z', '')
    digits = city.tr('^0-9', '')
    selected = negs.select {|neg| city.downcase.include?(neg) }
    city.capitalize!
    city = city.split(" ").map(&:capitalize).join(" ") if city.include?(" ")

    (alpha.nil? || alpha.length == 2 || digits != "") || (selected.any?) ? nil : city
  end

  def state_qualifier(state, negs)
    return if state.nil?
    alpha = state.tr('^A-Za-z', '')
    digits = state.tr('^0-9', '')
    selected = negs.select {|neg| state.downcase.include?(neg) }

    (digits != '' || alpha == '' || alpha.length != 2) || (selected.any?) ? nil : state
  end

  def zip_qualifier(zip, negs)
    return if zip.nil?
    alpha = zip.tr('^A-Za-z', '')
    digits = zip.tr('^0-9', '')
    selected = negs.select {|neg| zip.downcase.include?(neg) }

    (digits == '' || digits.length != 5 || alpha != '') || (selected.any?) ? nil : zip
  end

  def filter(str, bad)
    if str.include?(bad)
      objs = str.split(bad)
      objs.delete_if {|x| x.blank?}
      objs = objs.uniq
      str = objs.map(&:strip).join(",")
    end
    str
  end

  # ================== NOT USED ==================
  def state_zip_get(item)
    ## Detects and parses zip and state from string, without affecting original string.
    if !item.nil?
      smash = item.gsub(" ", "")
      smash.strip!
      alphanum = smash.tr('^A-Z0-9', '')

      if alphanum.length == 7 && smash == alphanum
        state_test = alphanum.tr('^A-Z', '')
        zip_test = alphanum.tr('^0-9', '')

        if state_test.length == 2 && zip_test.length == 5
          state = state_test
          zip = zip_test
          item = state+zip
        else
          item = nil
        end
      end
    end
    item
  end

  def ph_check(string)
    ### USED FOR ALL TEMPLATES - STRICT QUALIFICATIONS!!!!!
    ### FORMATS PHONE AS: (000) 000-0000
    if !string.blank? && string != "N/A" && string != "0" && (string.include?("(") || string.include?("-") || string.include?("."))
      if string[0] == "0" || string[0] == "1"
        stripped = string[1..-1]
      else
        stripped = string
      end

      # smash = stripped.gsub(/[^A-Za-z0-9]/, "")
      digits = stripped.tr('^0-9', '')
      # if smash == digits && digits.length == 10
      if digits.length == 10
        phone = "(#{digits[0..2]}) #{(digits[3..5])}-#{(digits[6..9])}"
      else
        phone = nil
      end
    else
      phone = nil
    end
    phone
  end
end
