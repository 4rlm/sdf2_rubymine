# class DealerfireRts
class AsDealerfire
  def initialize
    @helper  = AsHelper.new
  end

  def scrape_act(noko_page)
    # v7_street = noko_page.at_css('.full-address .address-1').text if noko_page.at_css('.full-address .address-1')
    # v7_city_st_zp = noko_page.at_css('.full-address .address-2').text if noko_page.at_css('.full-address .address-2')
    addr_hash = find_address(noko_page)

    act_scrape_hsh = {
    org: org = find_organization(noko_page),
    street: addr_hash[:street],
    city: addr_hash[:city],
    state: addr_hash[:state],
    zip: addr_hash[:zip],
    phone: noko_page&.at_css('.contactWrap .hidden-text')&.text }

    return act_scrape_hsh
  end


  ########## HELPER METHODS BELOW ##########

  def find_organization(noko_page)
    ### ORG: Copyright includes Org (Account Name).  Ranked based on reliability.
    if noko_page.at_css('.location-name')
      org = noko_page.at_css('.location-name')&.text
    elsif noko_page.at_css('.footer-name')
      org = noko_page.at_css('.footer-name')&.text
    elsif noko_page.at_css('.ws-info-dealer')
      org = noko_page.at_css('.ws-info-dealer')&.text
    elsif noko_page.at_css('.layout-footer .links')
      org = copyright_extractor(noko_page.at_css('.layout-footer .links')&.text)
    elsif noko_page.at_css('.bottom-footer .links')
      org = copyright_extractor(noko_page.at_css('.bottom-footer .links')&.text)
    elsif noko_page.at_css('.dealer-name')
      org = noko_page.at_css('.dealer-name')&.text
    end

    org = store_info_helper(org)
  end

  def find_address(noko_page)
    ### FULL ADDRESS: RANKED BY MOST RELIABLE. ###
    street1 = noko_page.at_css('.location-address')&.text
    city_state_zip1 = noko_page.at_css('.location-state')&.text
    street2 = noko_page.at_css('.footer-address')&.text
    city_state_zip2 = noko_page.at_css('.footer-state')&.text

    if street1 && city_state_zip1
      add = "#{street1}, #{city_state_zip1}"
    elsif !noko_page.css('.dealer-address').blank?
      add = noko_page.css('.dealer-address')&.text
    elsif street2 && city_state_zip2
      add = "#{street2}, #{city_state_zip2}"
    elsif noko_page.at_css('.header-address')
      add = noko_page.at_css('.header-address')&.text
    elsif noko_page.at_css('.layout-header .address')
      add = noko_page.at_css('.layout-header .address')&.text
    elsif noko_page.at_css('.layout-footer .ws-contact-text')
      add = noko_page.at_css('.layout-footer .ws-contact-text')&.text
    elsif noko_page.at_css('.foot-location')
      add = noko_page.at_css('.foot-location')&.text
    elsif !noko_page.css('.full-address').blank?
      add = noko_page.css('.full-address')&.text
    elsif !noko_page.css('.top-footer p').blank?
      add = noko_page.css('.top-footer p')&.text
    elsif noko_page.at_css('.ws-info-address')
      add = noko_page.at_css('.ws-info-address')&.text
    elsif !noko_page.css('.contact .footer-address').blank?
      add = noko_page.css('.contact .footer-address')&.text
    end

    addr_arr = addr_get(add) if add
    addr_hash = {}
    if addr_arr
      addr_hash[:street] = addr_arr[0]
      addr_hash[:city] = addr_arr[1]
      addr_hash[:state] = addr_arr[2]
      addr_hash[:zip] = addr_arr[3]
    end
    addr_hash
  end

  def addr_get(info)
    ### FOR DealerFire RTS: Extracts full addr from "store info" section.
    info = nil if info.include?("\t\tClick Here for Locations\n\t")

    if info
      if info.include?("Map/Hours")
        info_arr = info.split(",")
        if info_arr[1].include?("\n")
          info_arr = info_arr[1].split("\n")
          street = info_arr[1]
          state_zip = info_arr[0]
        end
      elsif info.include?("Store Info\n")
        info_arr = info.split("\n")
        phone = info_arr[4]
        street = info_arr[2]
        city_state_zip = info_arr[3]
      elsif info.include?("Get Directions")
        info_arr = info.split("|")
        street = info_arr[0]
        city_state_zip = info_arr[1]
      elsif info.include?(",")
        com_cnt = info.count(",")
        info_arr = info.split(",")

        if com_cnt == 1
          street = info_arr[0]
          state_zip = info_arr[1]
        elsif com_cnt == 2
          street = info_arr[0]
          city = info_arr[1]
          state_zip = info_arr[2]
        end
      end

      if city_state_zip
        city_state_zip_arr = city_state_zip.split(",")
        city = city_state_zip_arr[0]
        state_zip = city_state_zip_arr[1]
      end

      if state_zip
        state_zip.strip!
        state_zip_arr = state_zip.split(" ")
        state = state_zip_arr[0]
        zip = state_zip_arr[1]
      end

      ### NEED HELP.  NOT REACTING, BUT WORKS ON REPL.
      ### http://www.avondalenissan.com
      ### http://www.germainnissan.com
      ### STREET: "4300 Morse Rd  \nColumbus, OH, 43230"

      # if street && street.include?("\n") && city == nil
      #     street_arr = street.split("\n")
      #     street = street_arr[0]
      #     city = street_arr[1]
      # end

      ### NEED HELP.  NOT REACTING, BUT WORKS ON REPL.
      ### http://www.avondalenissan.com
      ### http://www.germainnissan.com
      ### STREET: "4300 Morse Rd  \nColumbus, OH, 43230"
      street = store_info_helper(street) unless nil
      city = store_info_helper(city) unless nil
      state = store_info_helper(state) unless nil
      zip = store_info_helper(zip) unless nil

      info = [street, city, state, zip]
    end
  end

  def store_info_helper(item)
    if item
      item.gsub!("  ", " ")
      item.gsub!("\t", "")
      item.gsub!("\n", "")
      item.strip!
      item
    end
  end

  def copyright_extractor(copyright)
    ### FOR DealerFire RTS: Extracts org from copyright footer.
    if copyright && (copyright.include?("©") || copyright.include?("Copyright"))
      copyright_arr = copyright.split("©")
      if copyright_arr[1].include?("\n")
        copyright_arr = copyright_arr[1].split("\n")
        copyright = copyright_arr[0].gsub!(/[^A-Za-z]/, " ")
        copyright.strip!
      end
    end
    copyright
  end
end
