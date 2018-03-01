# class DealercarSearchRts
class AsDealercarSearch
  def initialize
    @helper = AsHelper.new
  end

  def scrape_act(noko_page)
    orgs, streets, cities, states, zips, phones, addrs = [], [], [], [], [], [], []

    orgs << noko_page.css('title')&.text
    orgs << noko_page.css('.sepBar')&.text
    streets << noko_page.at_css('.LabelAddress1')&.text
    phones << noko_page.at_css('.LabelPhone1')&.text

    addr_n_ph1 = noko_page.at_css('.AddressPhone_Main')&.text
    [addr_n_ph1].each do |x|
      divided = @helper.addr_ph_divider(x)
      addrs.concat(divided)
      phones.concat(divided)
    end

    city_state_zip = noko_page.at_css('.LabelCityStateZip1')&.text
    [city_state_zip].each do |x|
      divided = @helper.city_state_zip_divider(x)
      cities << divided[:city] if !divided[:city].blank?
      states << divided[:state] if !divided[:state].blank?
      zips << divided[:zip] if !divided[:zip].blank?
    end

    addrs.each do |addr|
      result = @helper.addr_processor(addr)
      streets << result[:street]
      cities << result[:city]
      states.concat(result[:states])
      zips.concat(result[:zips])
      phones.concat(result[:phones])
    end

    orgs = @helper.org_processor(orgs)

    ### Call Methods to Process above Data
    act_scrape_hsh = {
    org:    @helper.final_arr_qualifier(orgs, "org"),
    street: @helper.final_arr_qualifier(streets, "street"),
    city:   @helper.final_arr_qualifier(cities, "city"),
    state:  @helper.final_arr_qualifier(states, "state"),
    zip:    @helper.final_arr_qualifier(zips, "zip"),
    phone:  @helper.final_arr_qualifier(phones, "phone") }

    return act_scrape_hsh
  end
end
