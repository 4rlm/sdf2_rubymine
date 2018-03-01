# class DealerDirectRts
class AsDealerDirect
  def initialize
    @helper = AsHelper.new
  end

  def scrape_act(noko_page)
    orgs, streets, cities, states, zips, phones = [], [], [], [], [], []

    orgs << noko_page.at_css('.dealer-name')&.text
    orgs << noko_page.at_css('title')&.text
    orgs << noko_page.at_css('.adr .org')&.text
    orgs << noko_page.at_css('.org')&.text
    orgs << noko_page.at_css('.dealer-title a alt')&.text

    phones << noko_page.at_css('span[@itemprop="telephone"]')&.text
    phones << noko_page.at_css('#CTN_primary')&.text
    phones << noko_page.at_css('.phones')&.text
    phones << noko_page.at_css('.dept_phn_num')&.text
    phones << noko_page.at_css('.phone1 .value')&.text
    phones << noko_page.at_css('#header-phone')&.text
    phones << noko_page.at_css('.PhoneNumber')&.text
    phones << noko_page.at_css('.department-phone-numbers')&.text

    streets << noko_page.at_css('span[@itemprop="streetAddress"]')&.text
    streets << noko_page.at_css('.adr .street-address')&.text
    streets << noko_page.at_css('.street-address')&.text

    cities << noko_page.at_css('span[@itemprop="addressLocality"]')&.text
    cities << noko_page.at_css('.adr .locality')&.text
    cities << noko_page.at_css('.locality')&.text

    states << noko_page.at_css('span[@itemprop="addressRegion"]')&.text
    states << noko_page.at_css('.adr .region')&.text
    states << noko_page.at_css('.region')&.text

    zips << noko_page.at_css('span[@itemprop="postalCode"]')&.text
    zips << noko_page.at_css('.adr .postal-code')&.text
    zips << noko_page.at_css('.postal-code')&.text

    addr1 = noko_page.at_css('#address')&.text
    addr2 = noko_page.at_css('.footer-address')&.text
    result_1 = @helper.addr_processor(addr1)
    result_2 = @helper.addr_processor(addr2)

    streets.concat([ result_1[:street], result_2[:street] ]) # [string, string ...]
    cities.concat([ result_1[:city], result_2[:city] ]) # [string, string ...]
    states.concat(result_1[:states] + result_2[:states]) # arrary + array + ....
    zips.concat(result_1[:zips] + result_2[:zips]) # arrary + array + ....
    phones.concat(result_1[:phones] + result_2[:phones]) # arrary + array + ....

    orgs = @helper.org_processor(orgs)

    ### Call Methods to Process above Data
    act_scrape_hsh = {
    org:   @helper.final_arr_qualifier(orgs, "org"),
    street: @helper.final_arr_qualifier(streets, "street"),
    city:   @helper.final_arr_qualifier(cities, "city"),
    state:  @helper.final_arr_qualifier(states, "state"),
    zip:    @helper.final_arr_qualifier(zips, "zip"),
    phone:  @helper.final_arr_qualifier(phones, "phone") }

    return act_scrape_hsh
  end
end
