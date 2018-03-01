#Call: CsvTool.new.import_uni_seeds('uni_act', 'cop_formated.csv')
#Call: Mig.new.migrate_uni_acts

module MigUniAct

  def migrate_uni_acts
    @brands = Brand.all

    # UniAct.all.each do |uni_act|
    # UniAct.find((1..603).to_a).each do |uni_act|
    UniAct.in_batches.each do |each_batch|
      each_batch.each do |uni_act|

        begin
          uni_hsh = uni_act.attributes
          uni_hsh = uni_hsh.symbolize_keys
          uni_hsh.delete(:id)
          uni_hsh.delete(:created_at)
          uni_hsh.delete(:updated_at)
          # uni_hsh.delete_if { |key, value| value.blank? }
          uni_act_array = uni_hsh.stringify_keys.to_a
          ##############################

          # WEB HASH: CREATED FROM uni_hsh
          urls = []
          urls << uni_hsh[:url1]
          urls << uni_hsh[:url2]
          urls&.uniq!
          urls&.reject!(&:nil?)
          formatted_urls = urls.map { |url| @formatter.format_url(url) } if urls.any?
          puts formatted_urls

          webs = []
          if formatted_urls.any?
            web_hsh = val_hsh(Web.column_names, uni_act_array.to_h)
            web_hsh.delete_if { |key, value| value.blank? }
            web_hsh[:brand_date] = Time.now

            formatted_urls.each do |url|
              http_s_hsh = @formatter.make_http_s(url)
              if http_s_hsh&.values&.compact&.present?
                web = Web.find_by(url: http_s_hsh[:https])
                web = Web.find_by(url: http_s_hsh[:http]) if !web.present?
                web = Web.create(url: url) if !web.present?
                web.update(web_hsh)
                webs << web if web.present?
              end
            end
          end
          ##############################


          # BRAND HASH: CREATED FROM uni_hsh
          if webs.any?
            brands = []
            brands << uni_hsh[:brand1]
            brands << uni_hsh[:brand2]
            brands << uni_hsh[:brand3]
            brands << uni_hsh[:brand4]
            brands << uni_hsh[:brand5]
            brands << uni_hsh[:brand6]
            brands&.flatten!
            brands&.uniq!
            brands&.reject!(&:nil?)

            if brands.any?
              brand_objs = brands.uniq.map do |brand|
                @brands.where(brand_name: brand)
              end

              if brand_objs.any?
                webs.each do |web|
                  brand_objs.each do |brand_obj|
                    web.brands << brand_obj if !web.brands.include?(brand_obj)
                  end
                  # web.brands << brand_objs
                  web.update(brand_sts: 'Valid')
                end
              end
            end
          end
          ##############################


          # ACT HASH: CREATED FROM uni_hsh
          act_hsh = val_hsh(Act.column_names, uni_act_array.to_h)
          act_name = act_hsh[:act_name]
          street = act_hsh[:street]
          city = act_hsh[:city]
          state = act_hsh[:state]
          zip = act_hsh[:zip]
          phone = act_hsh[:phone]
          act_hsh[:act_name] = @formatter.format_act_name_lite(act_name) if act_name.present?
          act_hsh[:street] = @formatter.format_street(street) if street.present?
          act_hsh[:city] = @formatter.format_city(city) if city.present?
          act_hsh[:state] = @formatter.format_state(state) if state.present?
          act_hsh[:zip] = @formatter.format_zip(zip) if zip.present?
          act_hsh[:phone] = @formatter.validate_phone(phone) if phone.present?
          act_hsh[:lat] = uni_hsh[:lat]
          act_hsh[:lon] = uni_hsh[:lon]

          act_hsh.delete_if { |key, value| value.blank? }
          act_name = act_hsh[:act_name]
          act_obj = save_comp_obj('act', {'act_name' => act_name}, act_hsh) if act_name.present?

          act_obj&.web = webs&.first
          # act_obj&.web = webs&.first if act_obj.present? && webs.any?
          ##############################

        rescue StandardError => error
          puts "\n\n=== RESCUE ERROR!! ==="
          puts error.class.name
          puts error.message
          print error.backtrace.join("\n")
          @rollbacks << uni_hsh
        end

      end ## end of batch iteration.
    end ## end of in_batches iteration

    UniAct.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('uni_acts')
  end

end
