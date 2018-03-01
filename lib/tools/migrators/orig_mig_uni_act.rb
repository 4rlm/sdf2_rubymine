# Note: Act CSV data uploads to UniAct Table.  Then MigUniAct parses it and migrates it to proper tables with associations.  Access parent in Mig class.

module MigUniAct

  #Call: Mig.new.migrate_uni_acts
  def migrate_uni_acts

    @rollbacks = []
    # UniAct.all.each do |uni_act|
    # UniAct.find((1..603).to_a).each do |uni_act|
    UniAct.in_batches.each do |each_batch|
      each_batch.each do |uni_act|

        begin
          act_hsh = uni_act.attributes
          act_hsh = act_hsh.symbolize_keys
          act_hsh.delete(:id)
          act_hsh.delete_if { |key, value| value.blank? }
          ##############################
          act_name = act_hsh[:act_name]
          street = act_hsh[:street]
          city = act_hsh[:city]
          state = act_hsh[:state]
          zip = act_hsh[:zip]
          phone = act_hsh[:phone]
          url = act_hsh[:url]
          ##############################
          act_hsh[:act_name] = @formatter.format_act_name_lite(act_name) if act_name.present?
          act_hsh[:street] = @formatter.format_street(street) if street.present?
          act_hsh[:city] = @formatter.format_city(city) if city.present?
          act_hsh[:state] = @formatter.format_state(state) if state.present?
          act_hsh[:zip] = @formatter.format_zip(zip) if zip.present?
          act_hsh[:phone] = @formatter.validate_phone(phone) if phone.present?
          act_hsh[:url] = @formatter.format_url(url) if url.present?
          ##############################
          act_hsh.delete_if { |key, value| value.blank? }
          act_name = act_hsh[:act_name]
          act_obj = save_comp_obj('act', {'act_name' => act_name}, act_hsh) if act_name.present?

        rescue StandardError => error
          puts "\n\n=== RESCUE ERROR!! ==="
          puts error.class.name
          puts error.message
          print error.backtrace.join("\n")
          @rollbacks << uni_hsh
        end

      end ## end of batch iteration.
    end ## end of in_batches iteration

    @rollbacks.each { |uni_hsh| puts uni_hsh }
    # UniAct.destroy_all

    UniAct.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('uni_acts')
  end

end
