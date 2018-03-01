#CALL: ContScraper.new.start_cont_scraper
class CsStandardScraper
  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page, full_staff_link, act_obj)
    cs_hsh_arr = []
    staffs_arr = []
    staffs_arr << noko_page.css(".ResponsiveStaff .row.gutter")
    staffs_arr << noko_page.css(".row.gutter")

    cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(staffs_arr)

    # staffs_arr << noko_page.css('section.acc_cont.gen_bg')
    # staffs_arr << noko_page.css('div.wpb_column.vc_column_container div.vc_row.wpb_row')
    # staffs_arr << noko_page.css('.team')

    # binding.pry

    cs_hsh_arr&.uniq!
    # binding.pry if !cs_hsh_arr.any?
    return cs_hsh_arr

    ##################################################
    # cs_hsh_arr << CsDealerCom.new.scrape_cont(noko_page)
    # cs_hsh_arr << CsCobalt.new.scrape_cont(noko_page)
    # cs_hsh_arr << CsDealeron.new.scrape_cont(noko_page)
    # cs_hsh_arr << CsDealerDirect.new.scrape_cont(noko_page)
    # cs_hsh_arr << CsDealerInspire.new.scrape_cont(noko_page)
    # cs_hsh_arr << CsDealerfire.new.scrape_cont(noko_page)
    # cs_hsh_arr << CsDealerEprocess.new.scrape_cont(noko_page)
    # cs_hsh_arr = cs_hsh_arr.flatten
  end

end
