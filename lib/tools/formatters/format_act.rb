#######################################
#CALL: ActScraper.new.start_act_scraper
#######################################

module FormatAct

  #######################################
  # CALL: Formatter.new.format_act_name_lite(act_name)
  def format_act_name_lite(act_name)
    if act_name.present?
      act_name&.gsub!(/\s/, ' ')&.strip
      act_name = act_name.split(' ').uniq.join(' ')
      act_name = remove_phones_from_text(act_name)
      punct_invalid_list = ["|", "/", ".", "&", ":", ";", "(", ")", "[", "]", "•", "!", "Inc", "INC", "LLC", "Llc", "llc"]
      punct_invalid_list.each { |inval| act_name&.gsub!(inval, ' ') }
      act_name = act_name.split(' ').reverse.uniq.reverse.join(' ') if act_name.present?
      act_name&.strip!
      act_name&.squeeze!(" ")
      return act_name
    end
  end

  #######################################
  # CALL: Formatter.new.format_act_name('act_name')
  def format_act_name(original_act_name)
    if original_act_name.present?
      original_act_name&.gsub!(/\s/, ' ')&.strip
      act_name = original_act_name
      # last_resort_act_name = process_difficult_act_name(act_name)

      city_state_hsh = get_city_state_from_act_name(act_name)
      city = city_state_hsh[:city]
      state = city_state_hsh[:state]
      # act_name = city_state_hsh[:act_name]

      city_state = nil
      if city.present? && state.present?
        city_state = "#{city}, #{state}"
      elsif state.present?
        city_state = state
      elsif city.present?
        city_state = city
      end

      dealer_name = check_dealer_in_name(act_name)
      brand_string = check_brand_in_name(act_name) if act_name.present?

      if dealer_name.present? && city_state.present?
        act_name = "#{dealer_name} #{brand_string} in #{city_state}"
      elsif dealer_name.present? && !city_state.present?
        act_name = "#{dealer_name} #{brand_string}"
      else
        act_name = "#{act_name} #{city_state}"
      end
      binding.pry

      act_name&.strip!
      act_name&.squeeze!(" ")
      act_name = act_name.split(' ').reverse.uniq.reverse.join(' ') if act_name.present?
      act_name.present? ? final_act_name = act_name : final_act_name = nil
      binding.pry
      return final_act_name
    end
  end






  #######################################
  ######### HELPER METHODS BELOW ########
  #######################################


  def process_difficult_act_name(act_name)
    ## For Act_Name without recognized brand, dealership, city, or state.  Instead of returning just 'Dealership'
    if act_name.present?
      act_name = act_name.split(' ').uniq.join(' ')

      punct_invalid_list = [".", ",", "&", ":", ";", ",", "(", ")", "[", "]", "•", "!"]
      punct_invalid_list.each { |inval| act_name&.gsub!(inval, ' ') }
      act_name = remove_phones_from_text(act_name)

      act_name = act_name.split("d/b/a")&.last
      act_name = act_name.split('www')&.first
      act_name = act_name.split('/').join(' ')

      if act_name.include?('|')
        name_parts = act_name.split('|')
        act_name = name_parts.first
      end

      if act_name.include?('- a ')
        name_parts = act_name.split('- a ')
        act_name = name_parts.first
      end

      if act_name.include?('- A ')
        name_parts = act_name.split('- A ')
        act_name = name_parts.first
      end

      if act_name.include?(' - ')
        name_parts = act_name.split(' - ')
        act_name = name_parts.first
      end

      if act_name.include?(' near ')
        name_parts = act_name.split(' near ')
        act_name = name_parts.first
      end

      act_name = act_name.split('-').map {|el| el.capitalize }.join('-')
      act_name.scan(/\d+|[a-zA-Z]+/).join(' ') if !act_name.include?('-')

      act_parts = act_name.split(' ')
      if act_parts.length < 2 && !act_name.include?('-')
        act_name = Formatter.new.cross_ref_all(act_name)
      end

      act_name = Formatter.new.letter_case_check(act_name) if act_name.present?

      if act_name.present?
        act_name = act_name.split(' ')&.each { |el| el[0] = el[0]&.upcase}&.join(' ')
        act_name = check_brand_in_name(act_name)

        act_name = Formatter.new.check_conjunctions(act_name) if act_name.present?
        act_name = act_name&.split(' ')&.each { |el| el[2] = el[2]&.upcase if el.downcase[0..1] == 'mc'}&.join(' ')

        apos_index = act_name&.index("'")
        if apos_index && (act_name[apos_index-1]&.scan(/[A-Z]/)&.any? || (act_name[apos_index-2] && act_name[apos_index-2] == ' '))
          act_name[apos_index+1] = '' if act_name[apos_index+1] == ' '
          act_name[apos_index+1] = act_name[apos_index+1].upcase
          act_name
        end

        more_invalid_list = ["One On One", "one on", "One On", "2017-2018"]
        more_invalid_list.each { |inval| act_name&.gsub!(inval, " ") }
        invalid_list = %w(2014 2015 2016 2017 2018 2019 2020 amp approved customers featuring inc incorporated inventory its llc opens preferred search selection serving welcome welcomes window your used co mt car cars source driving heartland since 1923 has ready for next test drive bad credit loans loan dealership dealer pre-owned preowned pre owned own metro alternative personal service parts part drivers driver parish provider automotive trucks suvs truck suv new selling vehicles vehicle full buy luxury sedans sedan financing finance certified near serves beyond specials huge meet best sales sale welcome trusted trust township shoppers shop visit premiere here save pay dealership dealer deal now with for and also by in at the is of a to servg experience spanish)

        inval_hsh = remove_invalids(act_name, invalid_list)
        act_name = inval_hsh[:act_name]
        act_name&.gsub!("Orleans", " New Orleans ")
        act_name&.gsub!("Flm", " FLM ")
        act_name&.gsub!("Ford-Lincoln", " FLM ")
        act_name&.gsub!("Ford-Lincoln-Mercury", " FLM ")
        act_name&.gsub!("Ford Lincoln Mercury", " FLM ")
        act_name&.gsub!("Lincoln-Mercury", " FLM ")
        act_name&.gsub!("Lincoln ", " FLM ")
        act_name&.gsub!("Ford ", " FLM ")
        act_name&.gsub!("Mercury", " FLM ")
        act_name&.gsub!("Chrysler Dodge Jeep Ram", " CDJR ")
        act_name&.gsub!("Chrysler Dodge Jeep" " CDJR ")
        act_name&.gsub!("Chrysler Jeep Dodge", " CDJR ")
        act_name&.gsub!("Ram Dodge Chrysler Jeep", " CDJR ")
        act_name&.gsub!("Chevrolet-Buick", " Chevrolet Buick ")
        act_name = act_name[0..45] if act_name

        act_name.present? ? final_act_name = act_name : final_act_name = nil
        return final_act_name
      end
    end
  end


  def get_city_state_from_act_name(act_name)
    if act_name.present?
      act_name = act_name.split(' ').uniq.join(' ')

      ## Removes Punctuation Chars from Act_Name ##
      punct_invalid_list = [".", ",", "&", ":", ";", ",", "(", ")", "[", "]", "•", "!"]
      punct_invalid_list.each { |inval| act_name&.gsub!(inval, ' ') }

      ## Removes Phone from Act_Name ##
      act_name = remove_phones_from_text(act_name)

      ## Gsub City Abreviations before running remove_invalids
      act_name&.gsub!("Sprgs", "Springs")
      act_name&.gsub!("Mtn", "Mountain")
      act_name&.gsub!('Ft', 'Fort')
      act_name&.gsub!('Saint', 'St')

      ## Gets City Name from Act_Name ##
      found_city_hsh = remove_city_from_act_name(act_name)
      found_city = found_city_hsh[:found_city]
      act_name = found_city_hsh[:act_name]

      ## Removes False-Positive State Abrevs from Act_Name ##
      act_name.split(' ').each do |act_name_part|
        act_name_part_dwn = act_name_part.downcase
        ['in', 'co', 'mt', 'me'].each do |inval|
          if inval.downcase == act_name_part_dwn
            act_name.gsub!(act_name_part, '')
          end
        end
      end

      ## Gets State from Act_Name ##
      state_parts = act_name.split(' ')
      state_hsh = find_states(state_parts)
      state_long = state_hsh[:state_long]
      state_short = state_hsh[:state_short]

      city_state_hsh = {act_name: act_name, city: found_city, state: state_short}
      return city_state_hsh
    end
  end


  def check_dealer_in_name(act_name)
    ### Search Act_Name for Proper Dealer Name ###
    dealer_list = Dealer.select(:dealer_name).order("id ASC").pluck(:dealer_name)
    temp_act_name = act_name.tr('^A-Za-z0-9', '')&.downcase
    dealer_names = dealer_list.select do |dealer|
      temp_dealer = dealer.tr('^A-Za-z0-9', '')&.downcase
      temp_act_name == temp_dealer || temp_act_name.include?(temp_dealer)
    end
    dealer_name = dealer_names&.first
    return dealer_name
  end


  # CALL: Formatter.new.check_brand_in_name(act_name)
  def check_brand_in_name(act_name)
    if act_name.present?
      act_name.gsub!('-', ' ')
      act_name.gsub!('/', ' ')
      act_name.gsub!('|', ' ')
      act_name.gsub!(',', ' ')
      act_name.gsub!('&', ' ')
      act_name.gsub!('.', ' ')
      temp_act_name_parts = act_name.tr('^A-Za-z', ' ').downcase.split(' ') - ['in']

      brands_found = []
      brands = Brand.select(:brand_name, :brand_term)
      temp_act_name_parts.each do |name_part|
        brands.find do |brand|
          brands_found << brand.brand_name if brand.brand_term == name_part
        end
      end

      brand_string = brands_found&.uniq&.join(' ')
      return brand_string
    end
  end


  # Formatter.new.remove_city_from_act_name('act_name')
  def remove_city_from_act_name(act_name)
    if act_name.present?
      name_parts = act_name.split(' in ')
      name_parts = act_name.split(' In ') if name_parts.length == 1
      name_parts = act_name.split(' Near Me ') if name_parts.length == 1
      name_parts = act_name.split(' near me ') if name_parts.length == 1
      name_parts = act_name.split(' of ') if name_parts.length == 1
      name_parts = act_name.split(' Located ') if name_parts.length == 1

      city_list = City.select(:city_name).order("id ASC").pluck(:city_name)

      if name_parts.length > 1
        found_cities = remove_city_from_act_name_helper(name_parts.last, city_list)
        (found_cities += remove_city_from_act_name_helper(act_name, city_list))&.uniq!
      else
        found_cities = remove_city_from_act_name_helper(act_name, city_list)
      end

      found_city = found_cities&.first
      act_name = (act_name.split(' ') - found_cities.join(' ').split(' ')).join(' ') if found_city
      found_city_hsh = { found_city: found_city, act_name: act_name }
      return found_city_hsh
    end
  end


  def remove_city_from_act_name_helper(name_section, city_list)
    if name_section
      name_parts = name_section.tr('^ A-Za-z', '')&.split(' ')&.uniq
      # city_list = City.select(:city_name).order("id ASC").pluck(:city_name)

      found_cities = []
      name_parts.each_with_index do |name_part, i|
        sngl_name_part = name_part.downcase
        dbl_name_part = "#{name_part} #{name_parts[i + 1]}"&.downcase
        city_list.find do |city|
          dwn_city = city.downcase
          found_cities << city if dbl_name_part == dwn_city || sngl_name_part == dwn_city
        end
      end

      found_cities&.uniq!
      found_cities.each_with_index do |item, i|
        dbl_name_part = found_cities[i + 1]
        found_cities.delete_at(i + 1) if dbl_name_part && item.include?(dbl_name_part)
      end
      return found_cities
    end
  end





end
