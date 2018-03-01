#CALL: FindPage.new.start_find_page
######### Delayed Job #########
# $ rake jobs:clear

require 'iter_query'
require 'noko'

class FindPage
  include IterQuery
  include Noko

  def initialize
    @dj_on = false
    @dj_count_limit = 0
    @dj_workers = 4
    @obj_in_grp = 40
    @dj_refresh_interval = 10
    @cut_off = 24.hour.ago
    @formatter = Formatter.new
    @db_timeout_limit = 60
    @mig = Mig.new
    # @count = 0
    # @make_urlx = FALSE
    # @tally_staff_links = Link.order("count DESC").pluck(:staff_link)
    # @tally_staff_texts = Text.order("count DESC").pluck(:staff_text)

    ## NOTE: REDO BELO...
    # @tally_staff_links = Dash.where(category: 'staff_link').order("count DESC").pluck(:focus)
    # @tally_staff_texts = Dash.where(category: 'staff_text').order("count DESC").pluck(:focus)
  end

  def get_query
    ## Invalid Sts Query ##
    query = Web.select(:id)
      .where(url_sts: 'Valid', page_sts: "Invalid")
      .where('page_date < ? OR page_date IS NULL', @cut_off)
      .order("id ASC").pluck(:id)

    ## Valid Sts Query ##
    val_sts_arr = ['Valid', nil]
    query = Web.select(:id)
      .where(url_sts: 'Valid', temp_sts: 'Valid', page_sts: val_sts_arr)
      .where('page_date < ? OR page_date IS NULL', @cut_off)
      .order("id ASC").pluck(:id) if !query.any?

    ## Error Sts Query ##
    err_sts_arr = ['Error: Timeout', 'Error: Host', 'Error: TCP']
    query = Web.select(:id)
      .where(url_sts: 'Valid', temp_sts: 'Valid', page_sts: err_sts_arr)
      .where('timeout < ?', @db_timeout_limit)
      .order("timeout ASC")
      .pluck(:id) if !query.any?

    puts "\n\nQuery Count: #{query.count}"
    sleep(1)
    # binding.pry
    return query
  end

  def start_find_page
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


  def template_starter(id)
    web = Web.find(id)
    web.links.destroy_all
    url = web.url
    temp_name = web.temp_name
    db_timeout = web.timeout
    db_timeout == 0 ? timeout = @dj_refresh_interval : timeout = (db_timeout * 3)
    puts "timeout: #{timeout}"
    puts "temp_name: #{temp_name}"
    puts url

    noko_hsh = start_noko(url, timeout)
    noko_page = noko_hsh[:noko_page]
    err_msg = noko_hsh[:err_msg]

    if err_msg.present?
      puts err_msg
      web.update(page_sts: err_msg, page_date: Time.now, timeout: timeout)
    elsif noko_page.present?
      link_text_results = find_links_and_texts(noko_page, web)
      if !link_text_results.any?
        web.update(page_sts: 'Invalid', page_date: Time.now, timeout: timeout)
      else
        link_text_results.each do |link_text_hsh|
          link_obj = Link.find_or_create_by(link_text_hsh)
          web_link = web.links.where(id: link_obj).exists?
          web.links << link_obj if !web_link.present?
          web.update(page_sts: 'Valid', page_date: Time.now, timeout: 0)
        end
      end
    end
  end


  def get_stocks(temp_name)
    special_templates = ["Cobalt", "Dealer Inspire", "DealerFire"]
    temp_name = 'general' if !special_templates.include?(temp_name)

    stock_texts = Term.where(sub_category: "staff_text").where(criteria_term: temp_name).map(&:response_term)
    # stock_texts += @tally_staff_texts
    # stock_texts.uniq!

    stock_links = Term.where(sub_category: "staff_href").where(criteria_term: temp_name).map(&:response_term)
    # stock_links += @tally_staff_links
    # stock_links.uniq!

    stock_hsh = {stock_texts: stock_texts, stock_links: stock_links}
    # puts stock_hsh
    # sleep(1)
    # binding.pry
    return stock_hsh
  end

  #CALL: FindPage.new.start_find_page
  def find_links_and_texts(noko_page, web)
    url = web.url
    temp_name = web.temp_name
    stock_hsh = get_stocks(temp_name)
    stock_texts = stock_hsh[:stock_texts]
    stock_links = stock_hsh[:stock_links]

    link_text_results = []
    noko_page.links.each do |noko_text_link|
      noko_text = noko_text_link.text&.downcase&.gsub(/\W/,'')
      pre_noko_link = noko_text_link&.href&.downcase&.strip
      noko_link = @formatter.format_link(url, pre_noko_link)

      if (noko_text && noko_link) && (noko_text.length > 3 && noko_link.length > 3) && (check_text_link_ban(noko_link, noko_text, temp_name) != true)
        ## Find any Texts or Links that include 'team' or 'staff'
        if noko_text.include?('staff') || noko_link.include?('staff')
          link_text_hsh = {staff_text: noko_text, staff_link: noko_link}
          link_text_results << link_text_hsh
        end

        ## Find valid Links
        stock_links.each do |stock_link|
          stock_link = stock_link.downcase&.strip
          if noko_link.include?(stock_link) || stock_link.include?(noko_link)
            link_text_hsh = {staff_text: noko_text, staff_link: noko_link}
            link_text_results << link_text_hsh
          end
        end

        ## Find valid Texts
        stock_texts.each do |stock_text|
          stock_text = stock_text.downcase&.gsub(/\W/,'')
          if noko_text.include?(stock_text) || stock_text.include?(noko_text)
            link_text_hsh = {staff_text: noko_text, staff_link: noko_link}
            link_text_results << link_text_hsh
          end
        end
      end
    end

    link_text_results.uniq!
    puts "\n\n===================="
    puts "Valid Text and Links: #{link_text_results.count}"
    puts link_text_results.inspect
    # sleep(1)
    # binding.pry
    # binding.pry if !link_text_results.any?
    return link_text_results
  end


  ############ HELPER METHODS BELOW ################


  def check_text_link_ban(staff_link, staff_text, temp_name)
    return true if !staff_link.present? || !staff_text.present? || staff_link.length < 4
    return true if (temp_name = "Cobalt" && staff_text == 'sales')
    return true if check_link_ban(staff_link)
    return true if check_text_ban(staff_text)

    include_ban = %w(/#card-view/card/ 404 appl approve body career center click collision commercial contact customer demo direction discl drive employ espanol espaol finan get google guarantee habla history home hour inventory javascript job join lease legal location lube mail map match multilingual offers oil open opportunit parts phone place price quick rating review sales_tab schedule search service special start yourdeal survey tel test text trade value vehicle video virtual websiteby welcome why facebook commercial twit near dealernear educat faculty discount event year fleet build index amenit tire find award year blog)

    banned_link_text = include_ban.find { |ban| staff_link.include?(ban) || staff_text.include?(ban) }
    banned_link_text.present? ? true : false
  end


  def check_text_ban(staff_text)
    if staff_text.present?
      ## Make sure staff_text is downcase and compact like below for accurate comparisons.
      banned_texts = %w(dealershipinfo porsche preowned aboutus ourdealership newcars cars about honda ford learnmoreaboutus news fleet aboutourdealership fordf150 fordtrucks fordtransitconnectwagon fordtransitconnectwagon fordecosport fordfusion fordedge fordfocus fordescape fordexpedition fordexpeditionmax fordcmaxhybrid fordexplorer fordcars fordflex fordtransitcargovan fordsuvs fordtransitconnect fordtransitwagon fordtransitconnectvan fordfusionenergi fordvans fordfusionhybrid fordmustang moreaboutus tourournewdealership tourourdealership)

      banned_text = banned_texts.find { |ban| staff_text == ban }
      banned_text.present? ? true : false
    end
  end


  def check_link_ban(staff_link)
    if staff_link.present?
      link_strict_ban = %w(/about /about-us /about-us.htm /about.htm /about.html /#commercial /commercial.html /dealership/about.htm /dealeronlineretailing_d /dealeronlineretailing /dealership/department.htm /dealership/news.htm /departments.aspx /fleet /index.htm /meetourdepartments /sales.aspx /#tab-sales)

      banned_link = link_strict_ban.find { |ban| staff_link == ban }
      banned_link.present? ? true : false
    end
  end


end
