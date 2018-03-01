# AsCobalt.new.scrape_act('noko_page', 'web_obj')

class AsCobalt
  def initialize
    @helper  = AsHelper.new
  end

  def scrape_act(noko_page)
    orgs, streets, cities, states, zips, phones = [], [], [], [], [], []

    ### OUTLYER: Special format, so doesn't follow same process as others below.
    ### === FULL ADDRESS AND ORG VARIABLE ===
    addr_n_org1 = noko_page.at_css('.dealer-info')&.text
    if !addr_n_org1.blank?
      addr_arr = @helper.addr_parser(addr_n_org1)
      city_state_zip = addr_arr[2]
      city_state_zip_arr = city_state_zip.split(",")
      state_zip = city_state_zip_arr[1]
      state_zip_arr = state_zip.split(" ") if state_zip

      orgs << addr_arr[0]
      streets << addr_arr[1]
      cities << city_state_zip_arr[0]
      states << state_zip_arr[0] if state_zip_arr
      zips << state_zip_arr[-1] if state_zip_arr
    end

    ### === PHONE VARIABLES ===
    phones.concat(noko_page.css('.contactUsInfo').map(&:children).map(&:text)) if noko_page.css('.contactUsInfo').any?
    phones << noko_page.at_css('.dealerphones_masthead')&.text
    phones << noko_page.at_css('.dealerTitle')&.text
    phones << noko_page.at_css('.cta .insight')&.text
    phones << noko_page.at_css('.dealer-ctn')&.text

    ### === ORG VARIABLES ===
    orgs << noko_page.at_css('.dealerNameInfo')&.text
    orgs.concat(noko_page.xpath("//img[@class='cblt-lazy']/@alt").map(&:value))
    orgs << noko_page.at_css('.dealer .insight')&.text
    orgs.concat(noko_page.css('.card .title').map(&:children).map(&:text)) if noko_page.css('.card .title').any?

    ### === ADDRESS VARIABLES ===
    addr2_sel = "//a[@href='HoursAndDirections']"
    addr2 = noko_page.xpath(addr2_sel)&.text
    addr3 = noko_page.at_css('.dealerAddressInfo')&.text
    addr_n_ph1 = noko_page.at_css('.dealerDetailInfo')&.text
    addr4 = noko_page.at_css('address')&.text
    addr4 = noko_page.at_css('address')&.text
    addr5 = noko_page.css('.card .content .text .copy span').map(&:children).map(&:text).join(', ') if noko_page.css('.card .content .text .copy span')

    result_1 = @helper.addr_processor(addr2)
    result_2 = @helper.addr_processor(addr3)
    result_3 = @helper.addr_processor(addr_n_ph1)
    result_4 = @helper.addr_processor(addr4)
    result_5 = @helper.addr_processor(addr5)

    streets.concat([ result_1[:street], result_2[:street], result_3[:street], result_4[:street], result_5[:street] ]) # [string, string ...]
    cities.concat([ result_1[:city], result_2[:city], result_3[:city], result_4[:city], result_5[:city] ]) # [string, string ...]
    states.concat(result_1[:states] + result_2[:states] + result_3[:states] + result_4[:states] + result_5[:states]) # arrary + array + ....
    zips.concat(result_1[:zips] + result_2[:zips] + result_3[:zips] + result_4[:zips] + result_5[:zips]) # arrary + array + ....
    phones.concat(result_1[:phones] + result_2[:phones] + result_3[:phones] + result_4[:phones] + result_5[:phones]) # arrary + array + ....

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
