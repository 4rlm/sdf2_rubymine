module Reporter


  # CALL: Reporter.db_totals_report
  def self.db_totals_report
    db_totals = CsvTool.new.get_db_table_list.sort.map do |e|
      [e.pluralize, e.constantize.all.count]
    end.to_h

    puts "\n\n#{'='*40}\n=== Report: DB Totals ==="
    puts db_totals.to_yaml
  end



  #CALL: Reporter.get_both_tallies
  # def self.get_both_tallies
  #   prep_tally
  #   tally_links
  #   tally_texts
  # end

  #CALL: Reporter.prep_tally
  # def self.prep_tally

    ## Format Term Texts
    # terms = Term.where(sub_category: "staff_text").map do |term|
    #   staff_text = term.response_term.downcase&.gsub(/\W/,'')
    #   staff_text = staff_text.strip
    #   term.update(response_term: staff_text)
    # end

    ## Format Term Hrefs
    # terms = Term.where(sub_category: "staff_href").map do |term|
    #   staff_href = term.response_term.downcase
    #   staff_href = "/#{staff_href}" if staff_href[0] != "/"
    #   staff_href = staff_href.strip
    #   term.update(response_term: staff_href)
    # end

    ######## SPECIAL-RARE ABOVE ####

    # Downcase and Compacts staff_text
  #   formatter = Formatter.new
  #   acts = Act.where.not(staff_text: nil).map do |act|
  #     staff_text = act.staff_text.downcase&.gsub(/\W/,'')
  #     staff_link = formatter.format_link(act.url, act.staff_link)
  #     act.update(staff_text: staff_text, staff_link: staff_link)
  #   end
  #
  #   ## ACTS - Make Nil
  #   make_nil_hsh = {cs_sts: nil, page_sts: nil, staff_text: nil, staff_link: nil }
  #   Act.where(staff_link: nil).each {|act| act.update(make_nil_hsh)}
  #   # Act.where("staff_link LIKE '%card%'").each {|act| act.update(staff_link: '/meetourdepartments')}
  #
  #   text_strict_ban = %w(porsche)
  #   text_strict_ban.each { |ban| Act.where(staff_text: ban).each {|act| act.update(make_nil_hsh)} }
  #   Act.where(temp_name: "Cobalt", staff_text: "sales").each {|act| act.update(make_nil_hsh)}
  #
  #   link_strict_ban = %w(/about /about-us /about-us.htm /about.htm /about.html /dealership/about.htm /dealership/department.htm /dealership/news.htm /departments.aspx /index.htm /meetourdepartments /sales.aspx /#tab-sales)
  #   link_strict_ban.each { |ban| Act.where(staff_link: ban).each {|act| act.update(make_nil_hsh)} }
  #
  #   light_ban = %w(404 appl approve body career center click collision contact customer demo direction discl drive employ espanol espaol finan get google guarantee habla history home hour inventory javascript job join lease legal lube mail map match multilingual offers oil open opportunit parts phone place price quick rating review sales_tab schedule search service special survey tel test text trade value vehicle video virtual websiteby welcome why)
  #
  #   light_ban.each do |ban|
  #     acts = Act.where("staff_link LIKE '%#{ban}%'").each {|act| act.update(make_nil_hsh)}
  #     acts = Act.where("staff_text LIKE '%#{ban}%'").each {|act| act.update(make_nil_hsh)}
  #   end
  # end

  # #CALL: Reporter.tally_links
  # def self.tally_links
  #   Link.destroy_all
  #   reset_primary_ids
  #
  #   # staff_links = Act.where.not(staff_link: nil).map { |act| act.staff_link }
  #   staff_links = Act.where(cs_sts: 'Valid').map { |act| act.staff_link }
  #   ranked_links = Hash[staff_links.group_by {|x| x}.map {|k,v| [k,v.count]}]
  #   sorted_links = ranked_links.sort_by{|k,v| v}.reverse.to_h
  #
  #   sorted_links.each do |link_arr|
  #     link_name = link_arr.first
  #     count = link_arr.last
  #
  #     if count > 3
  #       link_hsh = {staff_link: link_name, count: count}
  #       link_obj = Link.find_by(staff_link: link_name)&.update(link_hsh)
  #       link_obj = Link.create(link_hsh) if !link_obj.present?
  #     end
  #   end
  #
  #   ## DELETE LINKS
  #   Link.where("staff_link like '%landing%'").destroy_all
  #   Link.where("staff_link like '%miscpage%'").destroy_all
  #   Link.where(staff_link: nil).destroy_all
  # end


  # #CALL: Reporter.tally_texts
  # def self.tally_texts
  #   Text.destroy_all
  #   reset_primary_ids
  #
  #   # staff_texts = Act.where.not(staff_text: nil).map { |act| act.staff_text }
  #   staff_texts = Act.where(cs_sts: 'Valid').map { |act| act.staff_text }
  #   ranked_texts = Hash[staff_texts.group_by {|x| x}.map {|k,v| [k,v.count]}]
  #   sorted_texts = ranked_texts.sort_by{|k,v| v}.reverse.to_h
  #
  #   sorted_texts.each do |text_arr|
  #     text_name = text_arr.first
  #     count = text_arr.last
  #
  #     if count > 3
  #       text_hsh = {staff_text: text_name, count: count}
  #       text_obj = Text.find_by(staff_text: text_name)&.update(text_hsh)
  #       text_obj = Text.create(text_hsh) if !text_obj.present?
  #     end
  #   end
  #
  #   ## DELETE TEXTS
  #   Text.where(staff_text: nil).destroy_all
  # end
  #
  #
  # #CALL: Reporter.tally_templates
  # def self.tally_templates
  #   templates = Act.where.not(temp_name: nil).map { |act| act.temp_name }
  #   ranked_temps = Hash[templates.group_by {|x| x}.map {|k,v| [k,v.count]}]
  #   sorted_temps = ranked_temps.sort_by{|k,v| v}.reverse.to_h
  #
  #   sorted_temps.each do |temp_arr|
  #     temp_name = temp_arr.first
  #     count = temp_arr.last
  #
  #     if count > 3
  #       temp_hsh = {temp_name: temp_name, count: count}
  #       puts temp_hsh
  #     end
  #
  #   end
  # end
  #
  #
  # def self.reset_primary_ids
  #   ActiveRecord::Base.connection.tables.each do |t|
  #     ActiveRecord::Base.connection.reset_pk_sequence!(t)
  #   end
  # end


end
