module FormatWeb
  ## IMPORTANT: format_web_orig.rb is combining everything, but needs to strictly be FORMATTER!!, which can be used generally by other unrelated processes.  Will take RAW DATA, NOT OBJECTS.  AND WILL RETURN FORMATTED DATA TO BE USED WITH MIGRATOR.

  ## Mig should send raw url here, then receive formatted url before sending it to be used in format_link_text.

  #CALL: Formatter.new.format_url(url)
  def format_url(url)

    begin
      url = url&.split('|')&.first
      url = url&.split('\\')&.first
      url&.gsub!(/\P{ASCII}/, '')
      url = url&.downcase&.strip
      return nil if url&.length < 7
      return nil if url.include?('cobaltgroup')
      return nil if url.include?('demo')
      return nil if url.include?('cdk')

      url&.gsub!("cms.dealer.com", "com")
      url&.gsub!("dealerconnection.com", "com")
      url&.gsub!("foxdealersites.com", "com")
      url&.gsub!(".websiteoutlook.com", "")

      2.times { remove_ww3(url) } if url.present?
      url = remove_slashes(url) if url.present?
      url&.strip!

      return nil if !url.present? || url&.include?(' ')
      url = url[0..-2] if url[-1] == '/'

      symbs = ['(', ')', '[', ']', '{', '}', '*', '@', '^', '$', '+', '!', '<', '>', '~', ',', "'"]
      return nil if symbs.any? {|symb| url&.include?(symb) }

      uri = URI(url)
      if uri.present?
        bad_exts = %w(au ca edu es gov in ru uk us)
        host_parts = uri.host&.split(".")
        bad_host_sts = host_parts&.map { |part| TRUE if bad_exts.any? {|ext| part == ext } }&.compact&.first
        url = nil if bad_host_sts

        # host_parts = uri.host.split(".")
        # if host_parts.count > 3
        #   url = host_parts
        #   return url
        # end

        host = uri.host
        scheme = uri.scheme
        if host.present? && scheme.present?
          url = "#{scheme}://#{host}"
        end

        url = "http://#{url}" if url[0..3] != "http"
        url = url.gsub("//", "//www.") if !url.include?("www.")

        bad_text_in_url = %w(approv avis budget business collis eat enterprise facebook financ food google gourmet hertz hotel hyatt insur invest loan lube mobility motel motorola parts quick rent repair restaur rv ryder service softwar travel twitter webhost yellowpages yelp youtube)
        url = nil if bad_text_in_url.any? {|bad_text| url&.include?(bad_text) }
        url = convert_to_scheme_host(url) if url.present?
        return url
      end

    rescue
      return nil
    end # rescue
  end # def
  ###### Supporting Methods Below #######


  #CALL: Formatter.new.remove_ww3(url)
  def remove_ww3(url)
    if url.present?
      url.split('.').map { |part| url.gsub!(part,'www') if part.scan(/ww[0-9]/).any? }
      url&.gsub!("www.www", "www")
    end
  end


  #CALL: Formatter.new.remove_slashes(url)
  def remove_slashes(url)
    # For rare cases w/ urls with mistaken double slash twice.
    if url.present? && url.include?('//')
      parts = url.split('//')
      return parts[0..1].join if parts.length > 2
    end
    return url
  end


  #CALL: Formatter.new.format_link(url, link)
  def format_link(url, link)
    if url.present? && link.present? && link.length > 3
      url = strip_down_url(url)
      link = strip_down_url(link)
      # link.slice!(url)
      link&.gsub!(url, '')
      link = link&.split('.net')&.last
      link = link&.split('.com')&.last
      link = link&.split('.org')&.last
      link = "/#{link.split("/").reject(&:empty?).join("/")}" if link.present?
      return link
    end
  end


  # Both Link and URL use this to make them equal for comparison, but only Link's changes save.  Not url.
  #CALL: Formatter.new.strip_down_url(url_4)
  def strip_down_url(url)
    if url.present?
      url = url.downcase.strip
      url = url.gsub('www.', '')
      url = url.split('://')
      url = url[-1]
      return url
    end
  end


  #CALL: Formatter.new.remove_invalid_links(link)
  def remove_invalid_links(link)
    if link.present?
      bad_links = %w(: .biz .co .edu .gov .jpg .net // afri anounc book business buy bye call cash cheap click collis cont distrib download drop event face feature feed financ find fleet form gas generat graphic hello home hospi hour hours http info insta inventory item join login mail mailto mobile movie museu music news none offer part phone policy priva pump rate regist review schedul school service shop site test ticket tire tv twitter watch www yelp youth)
      symbs = ['(', ')', '[', ']', '{', '}', '*', '@', '^', '$', '%', '+', '!', '<', '>', '~', ',', "'"]
      bad_links += symbs

      make_link_nil = bad_links.any? {|word| link&.include?(word) }  ## .try and &.
      link = nil if (make_link_nil || link == "/")
      link = nil if link&.length&.> 60    ## .try and &.
      return link
    end
  end


  def remove_invalid_texts(text)
    if text.present?
      bad_texts = %w(? .com .jpg @ * afri after anounc apply approved blog book business buy call care career cash charit cheap check click collis commerc cont contrib deal distrib download employ event face feature feed financ find fleet form gas generat golf here holiday hospi hour info insta inventory join later light login mail mobile movie museu music news none now oil part pay phone policy priva pump quick quote rate regist review saving schedul service shop sign site speci ticket tire today transla travel truck tv twitter watch youth)
      symbs = ['{', '}', '*', '@', '^', '$', '%', '+', '!', '<', '>', '~']
      bad_texts += symbs

      text = text.split('|').join(' ')
      text = text.split('/').join(' ')

      text&.gsub!("(", ' ')
      text&.gsub!(")", ' ')
      text&.gsub!("[", ' ')
      text&.gsub!("]", ' ')
      text&.gsub!(",", ' ')
      text&.gsub!("'", ' ')

      text = nil if text&.length&.> 35  ## .try and &.
      invalid_text = Regexp.new(/[0-9]/)
      text = nil if invalid_text&.match(text) ## .try and &.
      text = text&.downcase   ## .try and &.
      text = text&.strip   ## .try and &.

      make_text_nil = bad_texts.any? {|word| text&.include?(word) }  ## .try and &.
      text = nil if make_text_nil
      return text
    end
  end



  #CALL: Formatter.new.convert_urls_to_uris
  def convert_urls_to_uris
    Web.where.not(url: nil).each do |web|
      url = web.url
      clean_url = convert_to_scheme_host(url)
      if (clean_url.present? && url.present?) && (clean_url != url)
        puts url
        puts clean_url
        binding.pry
        web.update(url: clean_url)
      end
    end
  end

  #CALL: Formatter.new.convert_to_scheme_host(url)
  def convert_to_scheme_host(url)
    if url.present?
      uri = URI(url)
      scheme = uri&.scheme
      host = uri&.host
      url = "#{scheme}://#{host}" if (scheme.present? && host.present?)
      return url
    end
  end


  # Call: Formatter.new.make_http_s('gp_url')
  def make_http_s(gp_url)
    if gp_url.present?
      uri = URI(gp_url)
      if uri.present?
        http_s_hsh = { http: "http://#{uri.host}", https: "https://#{uri.host}" }
        return http_s_hsh
      end
    end
  end







  ## Should get pre-formatted url from Mig.  Assumes url is already formatted.
  def format_link_or_text(url)
    return url
  end


  #### ALL OF BELOW NEEDS TO BE SEPARATED OUT OR DELETED  ####


  def migrate_web_and_links(web_obj)
  # Call: Formatter.new.format_webs

  # Call: Formatter.new.migrate_web_and_links(web_obj)

  # IMPORTANT: MIGHT NEED TO ADAPT AND INTEGRATE THIS WITH Mig.new.migrate_uni_acts via lib/tools/migs/uni_mig.rb
  ## MIGHT NOT NEED LOGIC BELOW, BECAUSE STAFF_PAGE AND LOCATIONS_PAGE COLUMNS WILL BE REMOVED. ##
  ## CONSIDER ADAPTING THIS FOR UniActs MIGRATOR TO PARSE UP WEB URL FIELDS INTO ASSOCIATIONS.
  ## 2 conditionals below format staff and locations page, then find or create Link object in links table, then save associations to web_obj.  Then remove staff and locations page link from Web object.

    url = format_url(web_obj.url)
    staff_link = web_obj.staff_page
    locations_link = web_obj.locations_page

    updated_web_hsh = {}
    updated_web_hsh = {url: url, staff_page: nil, locations_page: nil}

    staff_link = format_link(url, staff_link) if staff_link
    staff_link_obj = save_link(web_obj, staff_link, 'staff') if staff_link

    locations_link = format_link(url, locations_link) if locations_link
    locations_link_obj = save_link(web_obj, locations_link, 'locations') if locations_link

    web_obj.update(updated_web_hsh)
  end



  #### ORIGINAL BELOW, DELETE AFTER TESTING BOTTOM REPLACEMENT ###

  def save_link(web_obj, link, link_type)
    link_obj = Link.find_by(link: link)
    link_obj = Link.create(link: link, link_type: link_type) if !link_obj
    ## Need to: Return link_obj, then create new method for below.
    web_obj.links << link_obj if !web_obj.links.include?(link_obj)
  end

  #### TESTING BELOW ###

  ## CONSIDER USING (similar to): save_comp_obj, OR save_simp_obj via Mig Class.

  ### BELOW REPLACES save_link ABOVE ###
  def save_link_or_text(web_obj, link, link_type) # Saves Link OR Text.
    link_obj = Link.find_by(link: link)
    link_obj = Link.create(link: link, link_type: link_type) if !link_obj
    ## Need to: Return link_obj, then create new method for below.
    web_obj.links << link_obj if !web_obj.links.include?(link_obj)
  end


  #### TESTING ABOVE ###




end
