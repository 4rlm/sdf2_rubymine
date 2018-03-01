#CALL: ContScraper.new.start_cont_scraper
######### Delayed Job #########
# $ rake jobs:clear

require 'iter_query'
require 'noko'

class ContScraper
  include IterQuery
  include Noko

  def initialize
    @dj_on = false
    @dj_count_limit = 0
    @dj_workers = 4
    @obj_in_grp = 40
    @dj_refresh_interval = 10
    @cut_off = 20.hours.ago
    @db_timeout_limit = 60
    @formatter = Formatter.new
    @mig = Mig.new
    @cs_helper = CsHelper.new
  end


  def get_query
    temp_names = ['Dealer.com', 'Cobalt', 'Dealer Inspire', 'DealerOn', 'DealerFire', 'DEALER eProcess', 'Dealer Direct']

    ## Valid Sts Query ##
    val_sts_arr = ['Valid', nil]
    query = Web.select(:id)
      .where(url_sts: 'Valid', temp_name: temp_names, page_sts: 'Valid', cs_sts: val_sts_arr)
      .where('cs_date < ? OR cs_date IS NULL', @cut_off)
      .order("id ASC").pluck(:id)

    ## Error Sts Query ##
    err_sts_arr = ['Error: Timeout', 'Error: Host', 'Error: TCP']
    query = Web.select(:id)
      .where(url_sts: 'Valid', temp_name: temp_names, page_sts: 'Valid', cs_sts: err_sts_arr)
      .where('cs_date < ? OR cs_date IS NULL', @cut_off)
      .order("id ASC").pluck(:id) if !query.any?

    puts "\n\nQuery Count: #{query.count}"
    sleep(1)
    # binding.pry
    return query
  end


  def start_cont_scraper
    query = get_query
    while query.any?
      setup_iterator(query)
      query = get_query
      break if !query.any?
    end
  end

  def setup_iterator(query)
    @query_count = query.count
    (@query_count & @query_count > @obj_in_grp) ? @group_count = (@query_count / @obj_in_grp) : @group_count = 2
    @dj_on ? iterate_query(query) : query.each { |id| template_starter(id) }
  end



  #CALL: ContScraper.new.start_cont_scraper
  def template_starter(id)
    web = Web.find(id)
    url = web.url
    temp_name = web.temp_name
    link_objs = web.links
    db_timeout = web.timeout
    db_timeout == 0 ? timeout = @dj_refresh_interval : timeout = (db_timeout * 3)
    @staff_scraped = false
    @error_msg = nil

    link_objs.each do |link_obj|
      act_link_obj = web.web_links.find_by(link_id: link_obj)
      staff_link = link_obj.staff_link
      cs_hsh_arr = []

      full_staff_link = "#{web.url}#{staff_link}"
      puts "full_staff_link: #{full_staff_link}"

      noko_hsh = start_noko(full_staff_link, timeout)
      noko_page = noko_hsh[:noko_page]
      err_msg = noko_hsh[:err_msg]
      act_update_hsh = { cs_date: Time.now }

      if err_msg.present?
        @error_msg = err_msg
      elsif noko_page.present?
        cs_hsh_arr = scrape_page(noko_page, temp_name)
        update_db(web, cs_hsh_arr, link_obj, act_link_obj) if cs_hsh_arr.present?
      end
    end
    update_web(web, timeout)
  end


  def scrape_page(noko_page, temp_name)
    case temp_name
    when "Dealer.com" ## Good
      cs_hsh_arr = CsDealerCom.new.scrape_cont(noko_page)
    when "Cobalt" ## Good - alpha
      cs_hsh_arr = CsCobalt.new.scrape_cont(noko_page)
    when "DealerOn" ## Good - alpha
      cs_hsh_arr = CsDealeron.new.scrape_cont(noko_page)
    when "Dealer Direct" ## Good - alpha
      cs_hsh_arr = CsDealerDirect.new.scrape_cont(noko_page)
    when "Dealer Inspire" ## Good - alpha
      cs_hsh_arr = CsDealerInspire.new.scrape_cont(noko_page)
    when "DealerFire" ## Good - alpha
      cs_hsh_arr = CsDealerfire.new.scrape_cont(noko_page)
    when "DEALER eProcess" ## Good - alpha
      cs_hsh_arr = CsDealerEprocess.new.scrape_cont(noko_page)
    when "Search Optics"
      # cs_hsh_arr = CsSearchOptics.new.scrape_cont(noko_page, full_staff_link, web)
      cs_hsh_arr = CsSearchOptics.new.scrape_cont(noko_page)
    when "fusionZONE"
      # cs_hsh_arr = CsFusionZone.new.scrape_cont(noko_page, full_staff_link, web)
      cs_hsh_arr = CsFusionZone.new.scrape_cont(noko_page)
    # else
    #   Need to create a generic scraper here for unknown templates.
    #   cs_hsh_arr = CsStandardScraper.new.scrape_cont(noko_page, full_staff_link, web)
    end
    return cs_hsh_arr
  end


  #CALL: ContScraper.new.start_cont_scraper
  def update_db(web, cs_hsh_arr, link_obj, act_link_obj)
    cs_hsh_arr.delete_if { |h| !h[:full_name].present? || !h[:job_desc].present? } if cs_hsh_arr.any?
    cs_hsh_arr.flatten! if cs_hsh_arr.present?
    puts cs_hsh_arr

    if cs_hsh_arr&.any?
      cs_hsh_arr.each do |cs_hsh|
        cs_hsh[:web_id] = web.id
        cs_hsh[:cs_date] = Time.now
        cs_hsh[:cs_sts] = 'Valid'

        cont_obj = web.conts.find_by(full_name: cs_hsh[:full_name])
        cont_obj.present? ? cont_obj.update(cs_hsh) : Cont.create(cs_hsh)
        # cont_obj = Cont.find_or_create_by(web_id: web.id, full_name: cs_hsh[:full_name]).update(cs_hsh)
        @staff_scraped = true
      end
    end
  end


  def update_web(web, timeout)
    if @staff_scraped
      cs_sts = 'Valid'
      timeout = 0
    elsif @error_msg.present?
      puts @error_msg
      cs_sts = @error_msg
    end
    web.update(cs_sts: cs_sts, cs_date: Time.now, timeout: timeout)
  end


end
