#CALL: ContScraper.new.start_cont_scraper

class CsDealerCom
  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page)
    noko_page.css('br').each{ |br| br.replace(", ") }
    raw_staffs_arr = []
    cs_hsh_arr = []
    ez_staffs = []

    ## Newer Style Below
    raw_staffs_arr << noko_page.css('table.wysiwyg-table td')
    raw_staffs_arr << noko_page.css("ul#staffList > li.staff")
    raw_staffs_arr << noko_page.css("div#staffList > div.staff")
    raw_staffs_arr << noko_page.css("div.employee-list .employee-details")
    raw_staffs_arr << noko_page.css("div.page-bd div.gridder-list")
    raw_staffs_arr << noko_page.css("div.content > .wysiwyg-table")

    raw_staffs_arr.map do |raw_staffs|
      ez_staffs += @cs_helper.extract_noko(raw_staffs) if raw_staffs.any?
    end

    cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(ez_staffs)
    # binding.pry if !cs_hsh_arr.any?
    return cs_hsh_arr



    # staffy = noko_page.css("ul#staffList li.staff")
    # ez_staffs = @cs_helper.extract_noko(staffy)

    # staffy = noko_page.css('#staffList')
    # staffy = noko_page.css('li')

    # noko_page.css('ul').css("li")
    # noko_page.css("div#staff-listing")
    # noko_page.css("ul#staffList li")
    # noko_page.css('div.staff-listing')
    # noko_page.css(".staffList")

    # noko_page.css('form')
    # page-bd
    # noko_page.css("div.page-bd")

    # noko_page.css(".employee-tile")
    # reviewsSection


    ## Older Style Below - Need to convert to new style above.
    staffs_arr << noko_page.css('.staffList .staff')
    staffs_arr << noko_page.css('page-bd .row')
    staffs_arr << noko_page.css('#team-container .gridder-list')
    staffs_arr << noko_page.css('.tight-0 .staff-rightside')
    staffs_arr << noko_page.css('#reviewsSection .employee-details-wrapper')
    staffs_arr << noko_page.css('.yui3-u-2-3 .wysiwyg-table')

    staffs << noko_page.css("div.staffList > div.staff")
    staffs << noko_page.css("div.page-bd > div.row")
    staffs << noko_page.css("div#team-container > div.gridder-list")
    staffs << noko_page.css("div.tight-0 > div.staff-rightside")
    staffs << noko_page.css("div.yui3-u-2-3 > div.wysiwyg-table")
    staffs.flatten!

    ### PRACTICE BELOW ###
    ez_staffs = []
    binding.pry

    staffs = []
    # staffs << noko_page.css('table.wysiwyg-table td')
    # staffs << extract_noko(noko_page.css('table.wysiwyg-table td'))


    noko_page.css('br').each{ |br| br.replace(", ") }
    noko_page.css('table.wysiwyg-table td')[1].text
    # => "Hello World"

    # doc.css('br').each{ |br| br.replace(" ") }
    # p doc.at('div').text
    # #=> "Hello World"


    staffs << noko_page.css('table.wysiwyg-table td')
    staffs_arr << staffs
    cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(staffs_arr)

    # staffs << noko_page.css('td')
    # staffy = noko_page.css('table.wysiwyg-table td')[0].text
    # page.css('table').css("a strong")


    staffs_arr << staffs
    # binding.pry

    cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(staffs_arr)
    # binding.pry
    # sleep(1)
    return cs_hsh_arr

    # staffs_arr&.each { |staff| staffs << staff }

    # if staffs.any?
    #   puts staffs.count
    #   binding.pry
    #   cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(staffs)
    # end

    ##### WORKING ABOVE ######

    # staffs = noko_page.css("div.yui3-u-2-3 > div.ddc-content.content-default")
    # staffs_arr.flatten!
    # staffs&.each { |staff| staffs_arr << staff }
    #
    # if staffs_arr.any?
    #   puts staffs_arr.count
    #   binding.pry
    # end

    # cs_hsh_arr = @cs_helper.standard_scraper(staffs_arr)
    # cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(staffs_arr)

    # binding.pry if !cs_hsh_arr.any?


    ##### TESTING BELOW ######
    # staffs_arr << noko_page.css('div.yui3-u-2-3 div.content')
    # staffs_arr << staffs_arr.first
    # noko_page.xpath("//div[@class='yui3-u-2-3']/div")
    # noko_page.xpath("//*[@class='content']/")
    # cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(staffs_arr)
    # staffs = noko_page.css("div.yui3-u-2-3 > div")&.first&.text


    ## Difficult Below ###
    ## When no contacts, check link: /meet-the-staff.htm, like below example.
    # https://www.birminghambmw.com/meet-the-staff.htm
    # https://www.birminghambmw.com/dealership/staff.htm

    ## Difficult Below ###
    ## Name and Position on same line. - Cobalt too.
    # "Trent Neely<br />General Manager" ## After running all, revisit to split by position.
    # http://www.bobbyrahalmotorcar.com/dealership/staff.htm

    ## Difficult Below ###
    ## Can't find correct class or id to grab anything.
    # http://www.superiorkia.com/meet-our-team.htm
    # staffs = noko_page.css('#empdiv .employeelistingblock') if !staffs.any?
    # staffs = noko_page.css('div.employeelistingblock') if !staffs.any?
    # staffs = noko_page.css('#sales')
  end

end
