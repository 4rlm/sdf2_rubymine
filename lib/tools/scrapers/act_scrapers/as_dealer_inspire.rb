# class DealerInspireRts
class AsDealerInspire
  def initialize
    @helper  = AsHelper.new
  end

  def scrape_act(noko_page)
    org = noko_page.at_css('.organization-name')&.text
    acc_phones = noko_page.css('.tel')&.collect {|phone| phone&.text }
    phone = acc_phones.join(', ')

    street = noko_page.at_css('.street-address')&.text

    if street && street.include?(",")
      street = street.split(",")
      street = street[0]
      if street.include?("  ")
        street = street.split(" ")
        street = street.join(" ")
      end
      street = street.strip
    end

    act_scrape_hsh = { org: org, street: street,
    city:   noko_page&.at_css('.locality')&.text,
    state:  noko_page&.at_css('.region')&.text,
    zip:    noko_page&.at_css('.postal-code')&.text,
    phone:  phone }

    return act_scrape_hsh
  end
end
