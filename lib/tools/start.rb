# Note: This is where to call high-level processes involving anything in the Tools Directory.

#Call: Start.method_name
class Start


  #Call: Start.mega_start
  def self.mega_start
    CsvTool.new.import_all_seed_files ## imports all seeds.
    VerUrl.new.start_ver_url ## verifies urls, redirects.
  end

  ##############################
  ###### IMPORTS-EXPORTS #######
  ##############################

  # 1) CALL: Start.import_all_seed_files
  def self.import_all_seed_files
    CsvTool.new.import_all_seed_files
  end

  # 2) CALL: Start.backup_entire_db
  def self.backup_entire_db
    CsvTool.new.backup_entire_db
  end

  # 3) CALL: Start.restore_all_backups
  def self.restore_all_backups
    CsvTool.new.restore_all_backups
  end

  ##############################
  ######### VERIFIERS ##########
  ##############################

  # 4) CALL: Start.start_ver_url
  def self.start_ver_url
    VerUrl.new.start_ver_url
  end
  ## Use with foreman start

  ##############################
  ########## FINDERS ###########
  ##############################

  # 5) CALL: Start.start_find_temp
  def self.start_find_temp
    FindTemp.new.start_find_temp
    ### REMEMBER TO RUN TIMEOUT QUERY ###
  end
    ## Use with foreman start

  # 6) CALL: Start.start_find_page
  def self.start_find_page
    FindPage.new.start_find_page
  end
    ## Use with foreman start

  ##############################
  ####### Google Places ########
  ##############################

  ## GP FOR ACTS -W/O- SCRAPER
  # 7) CALL: Start.start_act_goog
  def self.start_act_goog
    GpAct.new.start_act_goog
  end

  ## GP FOR ACTS -AND- SCRAPER
  # 8) CALL: Start.start_act_scraper
  def self.start_act_scraper
    ActScraper.new.start_act_scraper
  end

  ################################
  ### CONT-SCRAPER (w/out GP) ####
  ################################

  # 8) CALL: Start.start_cont_scraper
  # def self.start_cont_scraper
  #   ContScraper.new.start_cont_scraper
  # end

  #######################################
end
