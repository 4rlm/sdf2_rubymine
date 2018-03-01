#CALL: ContScraper.new.start_cont_scraper

class CsCobalt
  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page)
    noko_page.css('br').each{ |br| br.replace(", ") }

    #### ORIGINAL BELOW ####
    staffs = noko_page.css("[@itemprop='employee']")

    cs_hsh_arr = []
    for i in 0...staffs.count
      staff_hash = {}
      staff_str = staffs[i].inner_html

      staff_hash[:first_name] = noko_page.css('span[@itemprop="givenName"]')[i].text.strip if noko_page.css('span[@itemprop="givenName"]')[i]
      staff_hash[:last_name] = noko_page.css('span[@itemprop="familyName"]')[i].text.strip if noko_page.css('span[@itemprop="familyName"]')[i]
      staff_hash[:job_desc]   = noko_page.css('[@itemprop="jobTitle"]')[i].text.strip   if noko_page.css('[@itemprop="jobTitle"]')[i]

      regex = Regexp.new("[a-z]+[@][a-z]+[.][a-z]+")
      matched_email = regex.match(staff_str)
      staff_hash[:email] = matched_email.to_s if matched_email

      # # Should find a common class within contact profile area.
      # [gh] phone is not listed for each employee.
      # staff_hash[:ph1] = noko_page.css('span[@itemprop="telephone"]')[i].text.strip if noko_page.css('span[@itemprop="telephone"]')[i]
      # staff_hash[:ph2] = noko_page.css('.link [@itemprop="telephone"]')[i].text.strip if noko_page.css('.link [@itemprop="telephone"]')[i]
      cs_hsh_arr << staff_hash
    end

    cs_hsh_arr = @cs_helper.prep_create_staffer(cs_hsh_arr) if cs_hsh_arr.any?


    ## Newer Style Below - Run if above is nil.
    if !cs_hsh_arr.any?
      raw_staffs_arr = []
      ez_staffs = []

      # binding.pry
      raw_staffs_arr << noko_page.css('div.deck .primary')
      raw_staffs_arr << noko_page.css('div.deck div.content')
      raw_staffs_arr << noko_page.css('div#staffList .staff')
      raw_staffs_arr << noko_page.css('ul#staffList .staff')
      raw_staffs_arr << noko_page.css('div.wpb_wrapper div.wpb_column')
      raw_staffs_arr << noko_page.css('div.container div.af-staff-member')
      raw_staffs_arr << noko_page.css('div.wpb_wrapper .desc_wrapper')
      raw_staffs_arr << noko_page.css('div.deck .text')
      raw_staffs_arr << noko_page.css('div#staffList .vcard')
      raw_staffs_arr << noko_page.css('div.staff-container .staff-item')
      raw_staffs_arr << noko_page.css('div.staffMember')
      raw_staffs_arr << noko_page.css('div.staff_no_link')
      raw_staffs_arr << noko_page.css('td')

      # binding.pry
      # ez_staffs = []
      # raw_staffs_arr << noko_page.css('td')

      raw_staffs_arr.map do |raw_staffs|
        ez_staffs += @cs_helper.extract_noko(raw_staffs) if raw_staffs.any?
      end

      cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(ez_staffs)
      return cs_hsh_arr


      ## Testing below ##
      # attributes = %w[src data-src data-react-src]
      # elem = noko_page.css("[@itemprop='src']")
      # attr = attributes.find { |attr| elem[attr] }
      # samps = noko_page[attr] if attr

      # binding.pry
      # raw_staffs_arr = []

      # Code to do the scraping
      # doc = RestClient.get('iframe_source_url')
      # parsed_doc = Nokogiri::HTML(doc)
      # parsed_doc.css('#yourSelectorHere') # or parsed_doc.xpath('...')

      #####################

      ## SCRAP YARD BELOW ##
      # raw_staffs_arr << noko_page.css('div.deck div.text')
      # raw_staffs_arr << noko_page.css('div#staffList .staff')
      # raw_staffs_arr << noko_page.css('.vc_row > .desc')
      # raw_staffs_arr << noko_page.css('.wpb_wrapper .desc_wrapper')
      # raw_staffs_arr << noko_page.css('.vc_row > .desc')

      # raw_staffs_arr << noko_page.css(".deck [@itemprop='employee']")
      # raw_staffs_arr << noko_page.css('.deck .card')
      # raw_staffs_arr << noko_page.css("div.content > .wysiwyg-table")
      # raw_staffs_arr << noko_page.css("[@itemprop='employee']")
      # raw_staffs_arr << noko_page.css('.wpb_row .vc_column_container')
      # raw_staffs_arr << noko_page.css('.wpb_row .desc_wrapper')
      # raw_staffs_arr << noko_page.css('#af-static .af-staff-member')
    end

    # binding.pry if !cs_hsh_arr.any?
    return cs_hsh_arr


    #############################
    ## IMPORTANT: ----> ## Check validity of staff links.  Replace bad ones with:
      # /MeetOurDepartments

    ## Difficult Below ###
    ## Name and Position on same line. - Dealer.com too.
    # "Trent Neely<br />General Manager" ## After running all, revisit to split by position.
    # http://www.arrowmitsubishi.com/staff/
  end
end
