#CALL: ContScraper.new.start_cont_scraper

class CsDealeron
  def initialize
    @cs_helper = CsHelper.new
  end


  def scrape_cont(noko_page)
    noko_page.css('br').each{ |br| br.replace(", ") }

    #### ORIGINAL BELOW ####
    staffs = noko_page.css('.staff-row .staff-title')
    staffs = noko_page.css(".staff-contact") if !staffs.any?

    cs_hsh_arr = []
    for i in 0...staffs.count
      staff_hash = {}

      staff_hash[:full_name] = noko_page.css('.staff-row .staff-title')[i].text.strip
      staff_hash[:job_desc] = noko_page.css('.staff-desc')[i] ? noko_page.css('.staff-desc')[i].text.strip : ""

      ph_email_hash = ph_email_scraper(staffs[i])

      if ph_email_hash
        staff_hash[:phone] = Formatter.new.validate_phone(ph_email_hash[:phone])
        staff_hash[:email] = @cs_helper.email_cleaner(ph_email_hash[:email])
      end

      cs_hsh_arr << staff_hash
    end

    cs_hsh_arr = @cs_helper.prep_create_staffer(cs_hsh_arr) if cs_hsh_arr.any?

    if !cs_hsh_arr.any?
      raw_staffs_arr = []
      ez_staffs = []

      raw_staffs_arr << noko_page.css('.staff-row .staff-title')
      raw_staffs_arr << noko_page.css('.staff-contact')
      raw_staffs_arr << noko_page.css('#staffList .staff')
      raw_staffs_arr << noko_page.css('#myTabContent .container_div')
      raw_staffs_arr << noko_page.css('.teamSection .teamMember')

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


  def ph_email_scraper(staff)
    if staff&.children&.any?
      info = {}
      value_1 = staff&.children[1]&.attributes["href"]&.value if staff.children[1]&.any?
      value_3 = staff&.children[3]&.attributes["href"]&.value if staff.children[3]&.any?

      info[:phone] = value_1 if value_1&.include?("tel:")
      info[:email] = value_1 if value_1&.include?("mailto:")
      info[:phone] = value_3 if value_3&.include?("tel:")
      info[:email] = value_3 if value_3&.include?("mailto:")
      return info
    end
  end


end
