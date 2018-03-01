module FormatAdr

  #CALL: Formatter.new.format_adr_hsh(adr_hsh)
  def format_adr_hsh(adr_hsh)
    adr_hsh.delete_if { |key, value| value.blank? } if !adr_hsh.empty?

    if adr_hsh.values.compact.present?
      street = adr_hsh[:street]
      city = adr_hsh[:city]
      state = adr_hsh[:state]
      zip = adr_hsh[:zip]

      street = format_street(street) if street.present?
      adr_hsh[:street] = street

      city = format_city(city) if city.present?
      adr_hsh[:city] = city

      (state = format_state(state)&.last) if state.present?
      adr_hsh[:state] = state

      zip = format_zip(zip) if zip.present?
      adr_hsh[:zip] = zip

      adr_hsh[:pin] = generate_pin(street, zip) if (street.present? && zip.present?)

      adr_hsh.delete_if { |key, value| value.blank? } if !adr_hsh.empty?
      return adr_hsh
    end

  end

  ######### FORMAT STREET ##########

  # CALL: Formatter.new.format_street(street)
  def format_street(street)
    street = street&.gsub(/\s/, ' ')&.strip
    if street.present?

      if street.present?
        street = Formatter.new.letter_case_check(street)
        street = " #{street} " # Adds white space, to match below, then strip.
        street&.gsub!(".", " ")
        street&.gsub!(",", " ")

        street&.gsub!(" North ", " N ")
        street&.gsub!(" South ", " S ")
        street&.gsub!(" East ", " E ")
        street&.gsub!(" West ", " W ")
        street&.gsub!(" Ne ", " NE ")
        street&.gsub!(" Nw ", " NW ")
        street&.gsub!(" Se ", " SE ")
        street&.gsub!(" Sw ", " SW ")

        street&.gsub!("Avenue", "Ave")
        street&.gsub!("Boulevard", "Blvd")
        street&.gsub!("Drive", "Dr")
        street&.gsub!("Expressway", "Expy")
        street&.gsub!("Freeway", "Fwy")
        street&.gsub!("Highway", "Hwy")
        street&.gsub!("Lane", "Ln")
        street&.gsub!("Parkway", "Pkwy")
        street&.gsub!("Road", "Rd")
        street&.gsub!("Route", "Rte")
        street&.gsub!("Street", "St")
        street&.gsub!("Terrace", "Ter")
        street&.gsub!("Trail", "Trl")
        street&.gsub!("Turnpike", "Tpke")
        street&.gsub!("|", " ")
        street&.gsub!("•", " ")
        street&.gsub!("Welcome to", " ")
        street&.gsub!("var address = \"", " ")

        street&.strip!
        street&.squeeze!(" ")
      end
    end
    return street
  end

  ########## FORMAT CITY ###########

  def format_city(city)
    city = city&.gsub(/\s/, ' ')&.strip
    city = nil if city&.scan(/[0-9]/)&.any?
    city = nil if city&.downcase&.include?('category')
    city = nil if city&.downcase&.include?('model')
    city = nil if city&.downcase&.include?('make')
    city = nil if city&.downcase&.include?('inventory')
    city = nil if city&.downcase&.include?('tracker')
    city = nil if city&.downcase&.include?('push')
    city = nil if city&.downcase&.include?("(")
    city = nil if city&.downcase&.include?(")")
    city = nil if city&.downcase&.include?("[")
    city = nil if city&.downcase&.include?("]")
    city&.gsub!("|", " ")
    city&.gsub!("•", " ")

    if city.present?
      street_types = %w(avenue boulevard drive expressway freeway highway lane parkway road route street terrace trail turnpike)
      invalid_city = street_types.find { |street_type| city.downcase.include?(street_type) }
      city = nil if invalid_city.present?

      if city.present?
        st_types = %w(ave blvd dr expy fwy hwy ln pkwy rd rte st ter trl tpke)
        city_parts = city.split(' ')

        invalid_city = city_parts.select do |city_part|
          st_types.find { |st_type| city_part.downcase == st_type }
        end

        city = nil if invalid_city.present?
        city = nil if city&.downcase&.include?("/")
        city = nil if city&.downcase&.include?("www")
        city = nil if city&.downcase&.include?("*")
        city = nil if city&.downcase&.include?("number")
        city = nil if city&.downcase&.include?("stock")
        city = nil if city&.downcase&.include?(":")
        city = nil if city&.downcase&.include?("ID")

        city&.strip!
        city&.squeeze!(" ")
        city = nil if city.present? && city.length > 50
        city = nil if city.present? && city.length < 4
      end
    end
    return city
  end

  ########## FORMAT STATE ##########

  def find_states(states)
    nested_states = []
    states.each { |state| nested_states << format_state(state) }
    nested_states_response = nested_states&.compact&.uniq
    state_pair = nested_states_response&.first

    state_long = state_pair&.first
    state_short = state_pair&.last
    state_hsh = { state_long: state_long, state_short: state_short }
    return state_hsh
  end


  def format_state(state)
    state = state&.gsub(/\s/, ' ')&.strip

    if state.present?
      states_hsh = { 'Alabama'=>'AL', 'Alaska'=>'AK', 'Arizona'=>'AZ', 'Arkansas'=>'AR', 'California'=>'CA', 'Colorado'=>'CO', 'Connecticut'=>'CT', 'Delaware'=>'DE', 'Florida'=>'FL', 'Georgia'=>'GA', 'Hawaii'=>'HI', 'Idaho'=>'ID', 'Illinois'=>'IL', 'Indiana'=>'IN', 'Iowa'=>'IA', 'Kansas'=>'KS', 'Kentucky'=>'KY', 'Louisiana'=>'LA', 'Maine'=>'ME', 'Maryland'=>'MD', 'Massachusetts'=>'MA', 'Michigan'=>'MI', 'Minnesota'=>'MN', 'Mississippi'=>'MS', 'Missouri'=>'MO', 'Montana'=>'MT', 'Nebraska'=>'NE', 'Nevada'=>'NV', 'New Hampshire'=>'NH', 'New Jersey'=>'NJ', 'New Mexico'=>'NM', 'New York'=>'NY', 'North Carolina'=>'NC', 'North Dakota'=>'ND', 'Ohio'=>'OH', 'Oklahoma'=>'OK', 'Oregon'=>'OR', 'Pennsylvania'=>'PA', 'Rhode Island'=>'RI', 'South Carolina'=>'SC', 'South Dakota'=>'SD', 'Tennessee'=>'TN', 'Texas'=>'TX', 'Utah'=>'UT', 'Vermont'=>'VT', 'Virginia'=>'VA', 'Washington'=>'WA', 'West Virginia'=>'WV', 'Wisconsin'=>'WI', 'Wyoming'=>'WY' }

      state = state.tr('^A-Za-z', '')
      if state.present? && state.length < 2
        state = nil
      elsif state.present? && state.length > 2
        state = state.capitalize
        states_hsh.map { |k,v| state = v if state == k }
      end

      if state.present?
        state.upcase!
        valid_state = states_hsh.find { |k,v| state == v }
        state_code = valid_state&.last
        return state_code
      end
    end
  end

  ########### FORMAT ZIP ###########

  #CALL: Formatter.new.format_zip(zip)
  def format_zip(zip)
    zip = nil if !zip.scan(/[0-9]/).length.in?([4,5,8,9])
    zip = zip&.gsub(/\s/, ' ')&.strip
    zip = zip&.split('-')&.first
    zip = nil if zip&.scan(/[A-Za-z]/)&.any?
    (zip = "0#{zip}" if zip.length == 4) if zip.present?
    (zip = nil if zip.length != 5) if zip.present?
    zip&.strip!
    zip&.squeeze!(" ")
    return zip
  end

  ############# ADR PIN ############

  # CALL: Formatter.new.generate_pin(street, zip)
  # def generate_pin(street, zip)
  #   if street && zip
  #     pin = nil
  #     street_parts = street.split(" ")
  #     street_num = street_parts[0]
  #     street_num = street_num.tr('^0-9', '')
  #     new_zip = zip.strip
  #     new_zip = zip[0..4]
  #     pin = "z#{new_zip}-s#{street_num}"
  #     return pin
  #   end
  # end


end
