# class DealerEprocessRts
class AsDealerEprocess
  def initialize
    @helper = AsHelper.new
  end

  def scrape_act(noko_page)
    orgs, streets, cities, states, zips, phones, addrs = [], [], [], [], [], [], []

    orgs << noko_page.at_css('.hd_site_title')&.text
    orgs << noko_page.at_css('#footer_site_info_rights')&.text
    orgs << noko_page.at_css('head title')&.text
    orgs << noko_page.at_css('#footer_seo_text_container h1')&.text
    orgs << noko_page.at_css('.dealer-name')&.text

    phones << noko_page.at_css('.phone-number')&.text
    phones << noko_page.at_css('.dept_number')&.text
    phones << noko_page.at_css('.hd_phone_no')&.text
    phones << noko_page.at_css('.banner-phones')&.text
    phones << noko_page.at_css('#contact-no')&.text

    org_n_addr1 = noko_page.css('#nav_group_1_col_1')&.text
    org_n_addr2 = noko_page.at_css('.footer_location_data')&.text

    [org_n_addr1, org_n_addr2].each do |x|
      divided = @helper.org_addr_divider(x)
      orgs << divided[:org] if !divided[:org].blank?
      addrs << divided[:addr] if !divided[:addr].blank?
    end

    addrs << noko_page.at_css('.address')&.text
    addrs << noko_page.at_css('.header_address')&.text
    addrs << noko_page.at_css('.banner-address')&.text
    addrs << noko_page.at_css('.subnav')&.text
    addrs << noko_page.at_css('.address-container')&.text

    addrs.each do |addr|
      result = @helper.addr_processor(addr)
      streets << result[:street]
      cities << result[:city]
      states.concat(result[:states])
      zips.concat(result[:zips])
      phones.concat(result[:phones])
    end

    orgs = remove_copyright(orgs) if orgs.present?
    orgs = @helper.org_processor(orgs) if orgs.present?

    ### Call Methods to Process above Data
    act_scrape_hsh = {
    org:    @helper.final_arr_qualifier(orgs, "org"),
    street: @helper.final_arr_qualifier(streets, "street"),
    city:   @helper.final_arr_qualifier(cities, "city"),
    state:  @helper.final_arr_qualifier(states, "state"),
    zip:   @helper.final_arr_qualifier(zips, "zip"),
    phone:  @helper.final_arr_qualifier(phones, "phone") }

    return act_scrape_hsh
  end


  def remove_copyright(orgs)
    if orgs.present?
      orgs.map do |org|
        org&.delete!("©") if org&.include?("©")
        org&.split("All Rights Reserved.")&.first if org&.include?("All Rights Reserved.")
      end
    end
  end

end
