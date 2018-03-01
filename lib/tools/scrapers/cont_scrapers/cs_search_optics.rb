#CALL: ContScraper.new.start_cont_scraper

class CsSearchOptics
  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page, full_staff_link, act_obj)
    cs_hsh_arr = []
    staffs_arr = []

    staffs_arr << noko_page.css(".staff")
    cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(staffs_arr)

    cs_hsh_arr&.uniq!
    # binding.pry if !cs_hsh_arr.any?
    return cs_hsh_arr

    ### STRUGGLE WITH EDGE CASES BELOW ###
    # staffs_arr << noko_page.css(".employee")
    # # noko_page.xpath("//img[@class='employee']/@alt").map(&:value)
    # noko_page.xpath("//*[@class='employee']/")
    # class_name = 'employee'
    # staffs_arr = noko_page.xpath("//*[@class=\"simpleWrapper\"]")
    # staffs_arr << noko_page.css(".employees-widget .simpleWrapper")
    # staffs_arr << noko_page.css(".employees-widget")
    # staffs_arr << noko_page.css(".simpleWrapper")
    # cs_hsh_arr << @cs_helper.consolidate_cs_hsh_arr(staffs_arr)
    # staffs_arr = noko_page.css(".employees-widget .employee")
    # staffs_arr = noko_page.css(".employees-widget .employee")
    # staffs_arr = noko_page.css(".employees-widget .employee")
  end
end
