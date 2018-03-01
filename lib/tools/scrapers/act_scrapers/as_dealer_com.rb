# AsDealerCom.new.scrape_act('noko_page', 'web_obj')

class AsDealerCom

  def initialize
    @helper = AsHelper.new
  end

  def scrape_act(noko_page)
    selector = "//meta[@name='author']/@content"

    act_scrape_hsh = {
    org:    noko_page&.xpath(selector)&.text,
    street: noko_page&.at_css('.adr .street-address')&.text,
    city:   noko_page&.at_css('.adr .locality')&.text,
    state:  noko_page&.at_css('.adr .region')&.text,
    zip:    noko_page&.at_css('.adr .postal-code')&.text,
    phone:  noko_page&.at_css('.value')&.text }

    return act_scrape_hsh
  end

end
