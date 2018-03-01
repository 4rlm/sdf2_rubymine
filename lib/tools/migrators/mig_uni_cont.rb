# Note: Cont CSV data uploads to UniCont Table.  Then MigUniCont parses it and migrates it to proper tables with associations.  Access parent in Mig class.

module MigUniCont

  #Call: Mig.new.migrate_uni_conts
  def migrate_uni_conts

    @rollbacks = []
    # UniCont.all.each do |uni_cont|
    # UniCont.find((1..100).to_a).each do |uni_cont|
    UniCont.in_batches.each do |each_batch|
      each_batch.each do |uni_cont|

        begin
          # UNI CONT HASH: FORMAT INCOMING DATA ROW FROM UniCont.
          uni_hsh = uni_cont.attributes
          uni_hsh = uni_hsh.symbolize_keys
          uni_hsh.delete(:id)
          uni_hsh.delete(:cont_id)
          uni_hsh[:url] = @formatter.format_url(uni_hsh[:url]) if uni_hsh[:url].present?
          uni_hsh.delete_if { |key, value| value.blank? }

          # CONT HASH: CREATED FROM uni_hsh
          uni_cont_array = uni_hsh.stringify_keys.to_a
          cont_hsh = val_hsh(Cont.column_names, uni_cont_array.to_h)
          non_cont_attributes_array = uni_cont_array - cont_hsh.stringify_keys.to_a

          # WEB OBJ: FIND, CREATE (saves association after act obj created)
          web_obj = save_simp_obj('web', {url: uni_hsh[:url]}) if uni_hsh[:url].present?

          # ACCOUNT OBJ: FIND, CREATE, UPDATE
          ## NEED TO FORMAT crma IF IT IS AN INDEXER 'ACT_SRC: WEB' URL. ##
          ## IF USING URL AS crma, IT NEEDS TO BE FORMATTED WHEN FINDING ACCOUNT WITH SAME URL!! ##

          act_hsh = val_hsh(Act.column_names, non_cont_attributes_array.stringify_keys.to_h)
          act_obj ||= Act.find_by(id: uni_hsh[:act_id]) || Act.find_by(crma: uni_hsh[:crma]) || web_obj&.acts&.first

          act_obj.present? ? update_obj_if_changed(act_hsh, act_obj) : act_obj = Act.create(act_hsh)
          cont_hsh[:act_id] = act_obj&.id

          # WEB OBJ: SAVE ASSOC
          create_obj_parent_assoc('web', web_obj, act_obj) if web_obj && act_obj

          # CONT OBJ: FIND, CREATE, UPDATE
          cont_hsh.delete_if { |key, value| value.blank? }

          if cont_hsh[:id].present?
            cont_obj = Cont.find_by(id: cont_hsh[:id])
          elsif uni_hsh[:crmc].present?
            cont_obj = Cont.find_by(crmc: uni_hsh[:crmc])
          elsif uni_hsh[:email]
            cont_obj = Cont.find_by(email: uni_hsh[:email])
          end

          # CONT OBJ: SAVE ASSOC
          cont_obj.present? ? update_obj_if_changed(cont_hsh, cont_obj) : cont_obj = Cont.create(cont_hsh)
          create_obj_parent_assoc('cont', cont_obj, act_obj) if cont_obj.present? && act_obj.present?

          # PHONE OBJ: FIND-CREATE, then SAVE ASSOC
          phone = @formatter.validate_phone(uni_hsh[:phone]) if uni_hsh[:phone].present?
          phone_obj = save_simp_obj('phone', {phone: phone}) if phone.present?
          create_obj_parent_assoc('phone', phone_obj, cont_obj) if phone_obj && cont_obj

          # TITLE OBJ: FIND-CREATE, then SAVE ASSOC
          title_obj = save_simp_obj('title', {job_title: uni_hsh[:job_title]}) if uni_hsh[:job_title].present?
          create_obj_parent_assoc('title', title_obj, cont_obj) if title_obj && cont_obj

          # DESCRIPTION OBJ: FIND-CREATE, then SAVE ASSOC
          description_obj = save_simp_obj('description', {job_desc: uni_hsh[:job_desc]}) if uni_hsh[:job_desc].present?
          create_obj_parent_assoc('description', description_obj, cont_obj) if description_obj && cont_obj

        rescue StandardError => error
          puts "\n\n=== RESCUE ERROR!! ==="
          puts error.class.name
          puts error.message
          print error.backtrace.join("\n")
          binding.pry
          @rollbacks << uni_cont
        end
      end ## end of iteration.
    end

    @rollbacks.each { |uni_cont| puts uni_cont }
    # UniCont.destroy_all

    UniCont.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('uni_conts')
  end

end
