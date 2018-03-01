# Note: Web CSV data uploads to UniWeb Table.  Then MigUniWeb parses it and migrates it to proper tables with associations (Web, Link, Text).  Access parent in Mig class.

module MigUniWeb

  #Call: Mig.new.migrate_uni_webs
  def migrate_uni_webs

    @rollbacks = []
    # UniWeb.all.each do |uni_web|
    # UniWeb.find((1..100).to_a).each do |uni_web|
    UniWeb.in_batches.each do |each_batch|
      each_batch.each do |uni_web|

        begin
          # FORMAT INCOMING DATA ROW FROM UniWeb.
          uni_web_hsh = uni_web.attributes
          uni_web_hsh['url'] = @formatter.format_url(uni_web_hsh['url']) if uni_web_hsh['url'].present?
          uni_web_hsh.delete('id')
          uni_web_hsh.delete('fwd_web_id')

          if uni_web_hsh['fwd_url'].present?
            uni_web_hsh['fwd_url'] = @formatter.format_url(uni_web_hsh['fwd_url'])
            fwd_url = uni_web_hsh['fwd_url']
            redirect_web_obj = save_simp_obj('web', {'url' => fwd_url}) if fwd_url.present?
            uni_web_hsh['fwd_web_id'] = redirect_web_obj&.id
          end


          # CREATE WEB HASH, AND VALIDATE
          uni_web_hsh.delete_if { |key, value| value.blank? }
          uni_web_array = uni_web_hsh.to_a
          web_hsh = val_hsh(Web.column_names, uni_web_array.to_h)
          url = web_hsh['url']
          web_obj = save_comp_obj('web', {'url' => url}, web_hsh) if url.present?

          non_web_attributes_array = uni_web_array - web_hsh.to_a
          link_text_hsh = non_web_attributes_array.to_h

          #########################
          ### LINK METHODS BELOW ###
          #########################

          # FORMAT staff_link
          staff_link = link_text_hsh['staff_link']
          link_text_hsh['staff_link'] = @formatter.format_link(url, staff_link) if staff_link.present?
          staff_link = link_text_hsh['staff_link']

          # FIND OR CREATE staff_link_obj
          if staff_link.present?
            staff_link_hsh = {link: staff_link, link_type: 'staff', link_sts: link_text_hsh['link_sts']}
            staff_link_hsh.delete_if { |key, value| value.blank? }
            staff_link_obj = save_comp_obj('link', {'link' => staff_link}, staff_link_hsh)
            create_obj_parent_assoc('link', staff_link_obj, web_obj) if staff_link_obj.present?
          end

          #########################
          # FORMAT locations_link
          locations_link = link_text_hsh['locations_link']
          link_text_hsh['locations_link'] = @formatter.format_link(url, locations_link) if locations_link.present?
          locations_link = link_text_hsh['locations_link']

          # FIND OR CREATE locations_link_obj
          if locations_link.present?
            locations_link_hsh = {link: locations_link, link_type: 'locations', link_sts: link_text_hsh['link_sts']}
            locations_link_obj = save_comp_obj('link', {'link' => locations_link}, locations_link_hsh)
            create_obj_parent_assoc('link', locations_link_obj, web_obj) if locations_link_obj.present?
          end

          #########################
          ### TEXT METHODS BELOW ###
          #########################


          # FORMAT staff_text
          staff_text = link_text_hsh['staff_text']
          link_text_hsh['staff_text'] = @formatter.remove_invalid_texts(staff_text) if staff_text.present?
          staff_text = link_text_hsh['staff_text']

          if staff_text.present?
            staff_text_hsh = {text: staff_text, text_type: 'staff', text_sts: link_text_hsh['slink_sts']}
            staff_text_hsh.delete_if { |key, value| value.blank? }
            staff_text_obj = save_comp_obj('text', {'text' => staff_text}, staff_text_hsh)
            create_obj_parent_assoc('text', staff_text_obj, web_obj) if staff_text_obj.present?
          end


          #########################
          # FIND OR CREATE locations_text_obj
          locations_text = link_text_hsh['locations_text']
          link_text_hsh['locations_text'] = @formatter.remove_invalid_texts(locations_text) if locations_text.present?
          locations_text = link_text_hsh['locations_text']

          if locations_text.present?
            locations_text_hsh = {text: locations_text, text_type: 'locations', text_sts: link_text_hsh['locations_link_sts']}
            locations_text_hsh.delete_if { |key, value| value.blank? }
            locations_text_obj = save_comp_obj('text', {'text' => locations_text}, locations_text_hsh)
            create_obj_parent_assoc('text', locations_text_obj, web_obj) if locations_text_obj.present?
          end

        rescue StandardError => error
          puts "\n\n=== RESCUE ERROR!! ==="
          puts error.class.name
          puts error.message
          print error.backtrace.join("\n")
          @rollbacks << uni_web_hsh
        end

      end ## end of batch iteration.
    end ## end of in_batches iteration

    # @rollbacks.each { |uni_web_hsh| puts uni_web_hsh }
    UniWeb.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('uni_webs')
  end

end
