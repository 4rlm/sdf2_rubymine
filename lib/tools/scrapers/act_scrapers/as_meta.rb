# require 'delayed_job' ## Might not need this linked here.

# class UnknownTemplate
class AsMeta

  def initialize
    @helper  = AsHelper.new
  end


  def scrape_act(noko_page)
    all_text = noko_page.at_css('body')&.text
    org = noko_page&.at_css('head title') ? noko_page&.at_css('head title')&.text : nil
    # as_phones = @helper.as_phones_finder(noko_page)
    state_zip_reg = Regexp.new("([A-Z]{2})[ ]?([0-9]{5})")

    begin
      state_zip_match_data = state_zip_reg.match(all_text) if state_zip_reg.match(all_text)
      if state_zip_match_data.present? #<MatchData "MI 48302" 1:"MI" 2:"48302">
        # Get state and zip
        state_zip = state_zip_match_data[0] # "MI 48302"
        state_zip_parts = state_zip&.split(' ')

        # Get combined street & city
        street_city_other = all_text.split(state_zip)&.first
        street_city_raw = street_city_other&.split("\n")[-1] # "\t\t\t  \t1234 Nice St Plano, "
        street_city_hsh = parse_street_city(street_city_raw)

        meta_hsh = {
        street: street_city_hsh[:street],
        city: street_city_hsh[:city],
        state: state_zip_parts&.first,
        zip: state_zip_parts&.last }
      else
        meta_hsh = { street: nil, city: nil, state: nil, zip: nil }
      end

    rescue
      puts "AS Meta Rescue Error"
      meta_hsh = { street: nil, city: nil, state: nil, zip: nil }
    end

    act_scrape_hsh = { org: org,
    street: street = meta_hsh[:street],
    city: meta_hsh[:city],
    state: meta_hsh[:state],
    zip: meta_hsh[:zip],
    phone: nil }

    return act_scrape_hsh
  end

  def parse_street_city(street_city_raw)
    street_city_raw = street_city_raw&.gsub(/\s/, ' ')&.strip
    street_city_raw = street_city_raw[0..-2] if street_city_raw.present? && street_city_raw[-1] == ','

    if street_city_raw.present?
      if street_city_raw.include?(',')
        street_city_parts = street_city_raw&.split(',')
      elsif street_city_raw.include?("•")
        street_city_parts = street_city_raw&.split("•")
      elsif street_city_raw.include?("|")
        street_city_parts = street_city_raw&.split("|")
      else
        street_city_parts = street_city_raw&.split(' ')
      end

      city = street_city_parts&.last
      street_city_parts&.delete(city) if city.present?
      street = street_city_parts.join(' ')
      {street: street, city: city}
    else
      {street: nil, city: nil}
    end

  end


end
