# Call: FindTemp.new.start_find_temp
######### Delayed Job #########
# $ rake jobs:clear

require 'iter_query'
require 'curler'
require 'noko'

class FindTemp
  include IterQuery
  include Noko

  def initialize
    @dj_on = false
    @dj_count_limit = 5
    @dj_workers = 4
    @obj_in_grp = 40
    @dj_refresh_interval = 10
    @db_timeout_limit = 60
    @cut_off = 30.hours.ago
    @mig = Mig.new
  end

  def get_query
    ## Valid Sts Query ##
    val_sts_arr = ['Valid', nil]
    query = Web.select(:id).where(url_sts: 'Valid', temp_sts: val_sts_arr).where('tmp_date < ? OR tmp_date IS NULL', @cut_off).order("id ASC").pluck(:id)

    ## Error Sts Query ##
    err_sts_arr = ['Error: Timeout', 'Error: Host', 'Error: TCP']
    query = Web.select(:id).where(url_sts: 'Valid', temp_sts: err_sts_arr).where('timeout < ?', @db_timeout_limit).order("timeout ASC").pluck(:id) if !query.any?

    puts "\n\nQuery Count: #{query.count}"
    sleep(1)
    # binding.pry
    return query
  end

  def start_find_temp
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
    web_url = web.url
    db_timeout = web.timeout
    db_timeout == 0 ? timeout = @dj_refresh_interval : timeout = (db_timeout * 3)
    puts "timeout: #{timeout}"

    if web.present?
      web_url = web.url
      noko_hsh = start_noko(web_url, timeout)
      noko_page = noko_hsh[:noko_page]
      err_msg = noko_hsh[:err_msg]

      if err_msg.present?
        puts err_msg
        web.update(temp_sts: err_msg, temp_name: 'Error: Search', tmp_date: Time.now, timeout: timeout)
      elsif noko_page.present?
        new_temp = Term.where(category: "find_temp").where(sub_category: "at_css").select { |term| term.response_term if noko_page&.at_css('html')&.text&.include?(term.criteria_term) }&.first&.response_term
        new_temp.present? ? temp_sts = 'Valid' : temp_sts = 'Unidentified'
        update_db(web, new_temp, temp_sts)
      end
    end
  end

  def update_db(web, new_temp, temp_sts)
    cur_temp = web.temp_name
    print_temp_results(web, cur_temp, new_temp, temp_sts)
    web.update(temp_sts: temp_sts, temp_name: new_temp, tmp_date: Time.now, timeout: 0)
  end

  def print_temp_results(web, cur_temp, new_temp, temp_sts)
    puts "\n\n================"
    puts "cur_temp: #{cur_temp}"
    puts "new_temp: #{new_temp}"
    puts "temp_sts: #{temp_sts}"
    puts "-----------------------"
  end

end

# Call: FindTemp.new.start_find_temp
