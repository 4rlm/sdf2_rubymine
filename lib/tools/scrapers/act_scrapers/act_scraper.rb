#######################################
#CALL: ActScraper.new.start_act_scraper
#######################################
require 'iter_query'
require 'noko'


class ActScraper
  include IterQuery
  include Noko

  def initialize
    @timeout = 10
    @dj_count_limit = 30 #=> Num allowed before releasing next batch.
    @workers = 5 #=> Divide format_query_results into groups of x.
  end


  def start_act_scraper
    query = Web.where(tmp_sts: 'Valid', as_sts: nil).order("updated_at ASC").pluck(:id)
    # query = Web.where(tmp_sts: 'Valid').order("updated_at ASC").pluck(:id)

    obj_in_grp = 50
    @query_count = query.count
    (@query_count & @query_count > obj_in_grp) ? @group_count = (@query_count / obj_in_grp) : @group_count = 2

    # iterate_query(query) # via IterQuery
    query.each { |id| template_starter(id) }
  end


  def template_starter(id)
    web_obj = Web.find(id)
    noko_hsh = start_noko(web_obj.url)
    noko_page = noko_hsh[:noko_page]
    err_msg = noko_hsh[:err_msg]

    if err_msg.present?
      puts err_msg
      web_obj.update(as_sts: err_msg, as_date: Time.now)
    elsif noko_page.present?
      template = web_obj&.templates&.order("updated_at DESC")&.first&.temp_name
      term = Term.where(response_term: template).where.not(mth_name: nil)&.first&.mth_name

      if term.present?
        case term
        when "as_dealer_com"
          as_hsh = AsDealerCom.new.scrape_act(noko_page)
        when "as_cobalt"
          as_hsh = AsCobalt.new.scrape_act(noko_page)
        when "as_dealeron"
          as_hsh = AsDealeron.new.scrape_act(noko_page)
        when "as_dealercar_search"
          as_hsh = AsDealercarSearch.new.scrape_act(noko_page)
        when "as_dealer_direct"
          as_hsh = AsDealerDirect.new.scrape_act(noko_page)
        when "as_dealer_inspire"
          as_hsh = AsDealerInspire.new.scrape_act(noko_page)
        when "as_dealerfire"
          as_hsh = AsDealerfire.new.scrape_act(noko_page)
        when "as_dealer_eprocess"
         as_hsh =  AsDealerEprocess.new.scrape_act(noko_page)
        else
          as_hsh = AsMeta.new.scrape_act(noko_page)
        end
        update_db(web_obj, as_hsh)
      else
        as_hsh = AsMeta.new.scrape_act(noko_page)
        update_db(web_obj, as_hsh)
      end
    end
  end


  def update_db(web_obj, as_hsh)
    if as_hsh&.values&.compact&.empty?
      web_obj.update(as_sts: 'Invalid:as', as_date: Time.now)
    else
      formatter = Formatter.new
      mig = Mig.new
      gp = GpApi.new

      ## Act: Format and Create Obj
      act_name = as_hsh[:org] if as_hsh[:org]
      act_name = act_name&.gsub(/\s/, ' ')&.strip
      orig_act_name = act_name

      if act_name.present? && !act_name.include?("Site Suspended")
        gp_hsh = gp.get_spot(act_name, web_obj.url)
        # gp_hsh = nil ## NIL FOR TESTING ONLY !!!
        if gp_hsh&.values&.compact&.present?
          act_name = gp_hsh[:act_name]
          adr_hsh = gp_hsh[:adr]
          gp_hsh[:adr_gp_sts].present? ? validity = gp_hsh[:adr_gp_sts] : validity = 'Valid:as-gp'

          gp_sts = gp_hsh[:gp_sts]
          web_hsh = {as_sts: validity, as_date: Time.now}
          binding.pry
          # web_hsh = web_hsh.merge(gp_sts)

          # web_hsh = { place_id: gp_hsh[:place_id], as_sts: validity, as_date: Time.now}
        else
          puts "No Result from Google Places"
          act_name = formatter.format_act_name(act_name)
          validity = 'Valid:as'
          adr_hsh = {street: as_hsh[:street], city: as_hsh[:city], state: as_hsh[:state], zip: as_hsh[:zip]}
          adr_hsh = formatter.format_adr_hsh(adr_hsh) if adr_hsh && adr_hsh.values.compact.present?
          web_hsh = {as_sts: validity, as_date: Time.now}
        end
      else
        puts "No Scraped Account Name"
        validity = 'Invalid:as-gp'
        act_name = 'Unidentified' if !act_name.present?
        web_hsh = {as_sts: validity, as_date: Time.now}
      end

      act_hsh = {act_src: 'Bot', act_sts: validity, act_name: act_name}
      act_obj = mig.save_comp_obj('act', {'act_name' => act_name}, act_hsh)
      mig.create_obj_parent_assoc('web', web_obj, act_obj) if act_obj.present?

      ## Adr: Format and Create Obj
      adr_hsh.delete_if { |key, value| value.blank? } if !adr_hsh.empty?
      adr_obj = mig.save_simp_obj('adr', adr_hsh) if adr_hsh && adr_hsh.values.compact.present?
      mig.create_obj_parent_assoc('adr', adr_obj, act_obj) if adr_obj.present?

      ## Phones: Format and Create Obj
      phone = as_hsh[:phone]
      phone_obj = mig.save_simp_obj('phone', {'phone' => phone}) if phone.present?
      mig.create_obj_parent_assoc('phone', phone_obj, act_obj) if phone_obj.present?

      web_obj.update(web_hsh)

      puts "\n\n\n================="
      puts orig_act_name
      puts "================="
      puts act_name
      puts "================="

      if web_obj
        puts "url: #{web_obj.url}"
      end

      if act_obj
        puts "----------------------"
        puts "act_src: #{act_obj.act_src}"
        puts "act_sts: #{act_obj.act_sts}"
        puts "act_name: #{act_obj.act_name}"
      end

      if adr_obj
        puts "----------------------"
        puts "adr_gp_sts: #{adr_obj.adr_gp_sts}"
        puts "street: #{adr_obj.street}"
        puts "city: #{adr_obj.city}"
        puts "state: #{adr_obj.state}"
        puts "zip: #{adr_obj.zip}"
        puts "pin: #{adr_obj.pin}"
      end

      puts "=================\n\n\n"
    end


  end


end
