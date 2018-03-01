module CsvImport

  ############## BEST CSV IMPORT METHOD #####################
  # RESTORE BACKUP METHODS BELOW - VERY QUICK PROCESS !!!
  # Re-Imports previously exported, formatted CSVs w/ ids, joins, assoc.
  # Imports CSV from: db/csv/backups/file_name.csv
  ###########################################################


  #CALL: CsvTool.new.restore_all_backups
  def restore_all_backups
    db_table_list = get_db_table_list
    db_table_list_hashes = db_table_list.map do |table_name|
      { model: table_name.classify.constantize, plural_model_name: table_name.pluralize }
    end

    db_table_list_hashes.each do |hsh|
      hsh[:model].delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!(hsh[:plural_model_name])
    end

    db_table_list_hashes.each do |hsh|
      restore_backup(hsh[:model], "#{hsh[:plural_model_name]}.csv")
    end

    ######### Reset PK Sequence #########
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end

  end


  # Call: CsvTool.new.restore_backup(Web, 'Webs.csv')
  # Call: CsvTool.new.restore_backup(WebBrand, 'WebBrands.csv')
  # Call: CsvTool.new.restore_backup(Who, 'Whos.csv')

  # Call: CsvTool.new.restore_backup(Brand, 'Brands.csv')
  # Call: CsvTool.new.restore_backup(Template, 'Templates.csv')

  def restore_backup(model, file_name)
    @file_path = "#{@backups_dir_path}/#{file_name}"
    parse_csv
    @headers.map!(&:to_sym)
    model.import(@headers, @rows, validate: false)
    completion_msg(model, file_name)
  end



  ############# WORST CSV IMPORT METHOD BELOW #############
  # IMPORT SEED METHODS BELOW - BIG PROCESS!!
  # Imports Raw Data files, which runs through extensive validations.
  # Imports CSV from: db/csv/seeds/file_name.csv
  ##########################################################


  #CALL: CsvTool.new.import_all_seed_files
  def import_all_seed_files
    Mig.new.reset_pk_sequence

    CsvTool.new.import_uni_seeds('uni_act', 'cop_formated.csv')

    # CsvTool.new.import_uni_seeds('uni_act', '1_acts_top_150.csv')
    # CsvTool.new.import_uni_seeds('uni_act', '2_wards_500.csv')
    # CsvTool.new.import_uni_seeds('uni_act', '3_acts_cop.csv')
    # CsvTool.new.import_uni_seeds('uni_act', '4_acts_sfdc.csv')
    # CsvTool.new.import_uni_seeds('uni_act', '5_acts_scraped.csv')
    # CsvTool.new.import_uni_seeds('uni_act', '6_acts_geo_locations.csv')


    ########## UNI SEED IMPORT BELOW ##########
    # CsvTool.new.import_uni_seeds('uni_web', '1_valid_uni_webs.csv')
    # CsvTool.new.import_uni_seeds('uni_web', '2_archived_uni_webs.csv')
    # CsvTool.new.import_uni_seeds('uni_web', '3_links_texts_uni_webs.csv')
    #
    # CsvTool.new.import_uni_seeds('uni_act', '4_crm_uni_acts.csv')
    # CsvTool.new.import_uni_seeds('uni_act', '5_indexers_uni_acts.csv')
    # CsvTool.new.import_uni_seeds('uni_act', '6_locations_uni_acts.csv')
    #
    # CsvTool.new.import_uni_seeds('uni_cont', '7_uni_conts.csv')
    #
    # ########## STANDARD SEED IMPORT BELOW ##########
    # CsvTool.new.import_standard_seeds('who', '8_whos.csv')
    # CsvTool.new.import_standard_seeds('brand', '9_brands.csv')
    # CsvTool.new.import_standard_seeds('term', '10_terms.csv')
  end


  ########## UNI SEED IMPORT BELOW ##########
  # CsvTool.new.import_uni_seeds('uni_act', '1_cops.csv')
  # CsvTool.new.import_uni_seeds('uni_act', '03_crm_uni_acts.csv')

  def import_uni_seeds(model_name, file_name)
    @file_path = "#{@seeds_dir_path}/#{file_name}"
    model = model_name.classify.constantize
    plural_model_name = model_name.pluralize
    custom_migrate_method = "migrate_#{plural_model_name}"
    parse_csv
    objs = []
    puts @clean_csv_hashes.count

    @clean_csv_hashes.each do |clean_csv_hsh|
      clean_csv_hsh = clean_csv_hsh.stringify_keys
      clean_csv_hsh.delete_if { |key, value| value.blank? } if !clean_csv_hsh.empty?
      uni_hsh = val_hsh(model.column_names, clean_csv_hsh)
      objs << model.new(uni_hsh)
    end

    model.import(objs)
    puts "\nSleep(3) - Complete: model.import(objs)\n#{model_name}, #{file_name}"
    sleep(3)

    Mig.new.send(custom_migrate_method)  ### NEED TO WORK ON THIS!!!
    puts "\nSleep(3) - Complete: Mig.new.#{custom_migrate_method}\n#{file_name}"
    sleep(3)

    completion_msg(model, file_name)
  end


  ########## STANDARD SEED IMPORT BELOW ##########

  def import_standard_seeds(model_name, file_name)
    @file_path = "#{@seeds_dir_path}/#{file_name}"
    model = model_name.classify.constantize
    plural_model_name = model_name.pluralize
    custom_migrate_method = "migrate_#{plural_model_name}"

    parse_csv
    objs = []
    @clean_csv_hashes.each do |clean_csv_hsh|
      clean_csv_hsh = clean_csv_hsh.stringify_keys
      clean_csv_hsh.delete_if { |key, value| value.blank? } if !clean_csv_hsh.empty?
      new_hsh = val_hsh(model.column_names, clean_csv_hsh)

      obj_exists = model.exists?(new_hsh) if new_hsh.present?
      obj = model.new(new_hsh) if !obj_exists
      objs << obj if obj
    end

    model.import(objs)
    puts "\nSleep(3) - Complete: model.import(objs)\n#{model_name}, #{file_name}"
    sleep(3)

    completion_msg(model, file_name)
  end


end
