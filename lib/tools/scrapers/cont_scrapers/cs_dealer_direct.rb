#CALL: ContScraper.new.start_cont_scraper

class CsDealerDirect
  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page)
    noko_page.css('br').each{ |br| br.replace(", ") }

    #### ORIGINAL BELOW ####
    cs_hsh_arr = []
    staff = noko_page.css('.staff-desc .staff-name')

    # if staff.any?
    for i in 0...staff.count
      staff_hash = {}

      staff_hash[:full_name] = noko_page.css('.staff-desc .staff-name')[i].text.strip
      staff_hash[:job_desc] = noko_page.css('.staff-desc .staff-title')[i] ? noko_page.css('.staff-desc .staff-title')[i].text.strip : ""
      staff_hash[:email] = noko_page.css('.staff-info .staff-email a')[i] ? noko_page.css('.staff-info .staff-email a')[i].text.strip : ""
      staff_hash[:phone] = noko_page.css('.staff-info .staff-tel')[i] ? noko_page.css('.staff-info .staff-tel')[i].text.strip : ""

      cs_hsh_arr << staff_hash
    end

    # elsif noko_page.css('.staff-info').any?
    #   staffs = noko_page.css('.staff-info')
    #   cs_hsh_arr = @cs_helper.standard_scraper(staffs)
    # end

    cs_hsh_arr = @cs_helper.prep_create_staffer(cs_hsh_arr) if cs_hsh_arr.any?

    if !cs_hsh_arr.any?
      raw_staffs_arr = []
      ez_staffs = []

      raw_staffs_arr << noko_page.css('.staff-body .row-fluid')
      raw_staffs_arr << noko_page.css('.staff-list .listed-item')
      raw_staffs_arr << noko_page.css('#staffList .staff')
      raw_staffs_arr << noko_page.css('.staff-info')

      raw_staffs_arr << noko_page.css('div#staff div.staff-info')
      ### FIRST AND LAST NAME MERGE TOGETHER.  NEED TO SEPARATE THEM.  COULD BE DUE TO THE ','.  CHECK IN:
      # 1) JOB_IDENTIFIER
      # 2) NAME_IDENTIFIER
      # 3) EXTRACT_NOKO

      # binding.pry
      # ez_staffs = []
      # raw_staffs_arr << noko_page.css('div#staff div.staff-info')


      raw_staffs_arr.map do |raw_staffs|
        ez_staffs += @cs_helper.extract_noko(raw_staffs) if raw_staffs.any?
      end

      cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(ez_staffs)

      # binding.pry if !cs_hsh_arr.any?
      return cs_hsh_arr
      # cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(raw_staffs_arr)
    end

    # binding.pry if !cs_hsh_arr.any?
    return cs_hsh_arr
  end
end
