#CALL: ContScraper.new.start_cont_scraper

class CsDealerfire
  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page)
    noko_page.css('br').each{ |br| br.replace(", ") }

    #### ORIGINAL BELOW ####
    staffs = noko_page.xpath("//div[@class='staffs-list']/div[@itemprop='employees']")
    cs_hsh_arr = []
    staffs.each do |staff|
      staff_hash = {}

      info_ori = staff.text.split("\n").map {|el| el.delete("\t") }
      infos = info_ori.delete_if {|el| el.blank?}

      jobs = noko_page.css("[@itemprop='jobTitle']").text
      names = noko_page.css("[@itemprop='name']").text

      infos.each do |info|
        num_reg = Regexp.new("[0-9]+")
        if jobs.include?(info)
          staff_hash[:job_desc] = info
        elsif names.include?(info)
          staff_hash[:full_name] = info
        elsif num_reg.match(info)
          staff_hash[:phone] = info
        end
      end

      data = staff.inner_html
      regex = Regexp.new("[a-z]+[@][a-z]+[.][a-z]+")
      email_reg = regex.match(data)
      staff_hash[:email] = email_reg.to_s if email_reg

      cs_hsh_arr << staff_hash
    end

    cs_hsh_arr = @cs_helper.prep_create_staffer(cs_hsh_arr) if cs_hsh_arr.any?

    if !cs_hsh_arr.any?
      raw_staffs_arr = []
      ez_staffs = []

      raw_staffs_arr << noko_page.css('.com-our-team-responsive2__staff-group .com-our-team-responsive2__employee')

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
