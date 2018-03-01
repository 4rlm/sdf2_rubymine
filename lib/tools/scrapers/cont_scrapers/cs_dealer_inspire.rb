#CALL: ContScraper.new.start_cont_scraper

class CsDealerInspire
  def initialize
    @cs_helper = CsHelper.new
  end

  # def scrape_cont(noko_page)
  #   staffs_arr = []
  #   staffs_arr << noko_page.css('.staff .staff-item')
  #   staffs_arr << noko_page.css('.staff-bio h3')
  #   staffs_arr << noko_page.css('.ict_content_cl .team-member')
  #   # staffs_arr << noko_page.css('')
  #
  #   cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(staffs_arr)
  #
  #   # binding.pry if !cs_hsh_arr.any?
  #   return cs_hsh_arr
  # end

  ##### Original ###
  def scrape_cont(noko_page)
    noko_page.css('br').each{ |br| br.replace(", ") }

    #### ORIGINAL BELOW ####
    staffs = noko_page.css('.staff-bio h3')

    cs_hsh_arr = []
    for i in 0...staffs.count
      staff_hash = {}
      # staff_hash[:full_name] = noko_page.xpath("//a[starts-with(@href, 'mailto:')]/@data-staff-name")[i].value
      # staff_hash[:job] = noko_page.xpath("//a[starts-with(@href, 'mailto:')]/@data-staff-title") ? noko_page.xpath("//a[starts-with(@href, 'mailto:')]/@data-staff-title")[i].value : ""
      staff_hash[:full_name] = noko_page.css('.staff-bio h3')[i] ? noko_page.css('.staff-bio h3')[i].text.strip : ""
      staff_hash[:job_desc] = noko_page.css('.staff-bio h4')[i] ? noko_page.css('.staff-bio h4')[i].text.strip : ""

      staff_hash[:email] = noko_page.css('.staff-email-button')[i] ? noko_page.css('.staff-email-button')[i].attributes["href"].text.gsub(/^mailto:/, '') : ""
      # staff_hash[:email] = noko_page.css('.staff-email-button')[i].attributes["href"] ? noko_page.css('.staff-email-button')[i].attributes["href"].text : ""
      staff_hash[:phone] = noko_page.css('.staffphone')[i] ? noko_page.css('.staffphone')[i].text.strip : ""

      cs_hsh_arr << staff_hash
    end

    cs_hsh_arr = @cs_helper.prep_create_staffer(cs_hsh_arr) if cs_hsh_arr.any?

    if !cs_hsh_arr.any?
      raw_staffs_arr = []
      ez_staffs = []

      raw_staffs_arr << noko_page.css('.staff .staff-item')
      raw_staffs_arr << noko_page.css('.staff-bio h3')
      raw_staffs_arr << noko_page.css('.ict_content_cl .team-member')

      raw_staffs_arr.map do |raw_staffs|
        ez_staffs += @cs_helper.extract_noko(raw_staffs) if raw_staffs.any?
      end

      cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(ez_staffs)

      # binding.pry if !cs_hsh_arr.any?
      return cs_hsh_arr
    end

    # binding.pry if !cs_hsh_arr.any?
    return cs_hsh_arr
  end
end
