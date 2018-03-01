## AboutTool provides direct access to each tool folder, but is not the only way.  Each tool class, module, or method can be accessed directly or via its parent.  This is highest level parent. AboutTool is also good place for testing to later deploy in other sections or to call collections of complex processes.

######### Delayed Job #########
# $ rake jobs:clear

######### Reset PK Sequence #########
# ActiveRecord::Base.connection.tables.each do |t|
#   ActiveRecord::Base.connection.reset_pk_sequence!(t)
# end

# CALL: CsvTool.new.db_totals_report
############################################

class AboutTool
  # Call: AboutTool.new

  def initialize
    puts "Welcome to AboutTools.  Highest level access to all tool folders."
  end


  ###############################################
  # Call: AboutTool.new.start_url_redirect
  # Call: VerUrl.new.starter

  def start_url_redirect
    puts ">> start_url_redirect..."
    binding.pry

    VerUrl.new
    # VerUrl.new.start_ver_url
    binding.pry

    # VerUrl.new.delay.start_ver_url
  end

  def application_master_program_starter
    # Call: AboutTool.new.application_master_program_starter

    # Note: There is also separate methods for importing new data and backing up existing db, but this is simply restoring db to previous save point, then running all processes from start to end.
    # To Backup, CALL: CsvToolMod::Export.backup_entire_db
    # To Import New or Additional Data, CALL: CsvToolMod::Import.import_entire_seeds

    puts "\n\n== AboutTool.new.application_master_program_starter ==\nDoes EVERYTHING! from A - Z!"
    msg_1 = "1) CsvToolMod::Import.restore_all_backups: Destroys contents of all tables."
    msg_2 = "2) Re-Imports each CSV backup to restore db"
    msg_3 = "3) Formatters: Formats the db data and parses when necessary."
    msg_4 = "4) VerUrl: Verifies & updates urls Valid/FWD."
    msg_5 = "5) TemplateGrabber: Verifies & updates (Dealer.com, Cobalt, etc.)."
    msg_6 = "6) LinkTextGrabber: Verifies & updates Links/Text (locations and staff pages)."
    msg_7 = "7) ActScraper"
    msg_8 = "8) ContScraper"
    msg_9 = "9) ApiScraper (verifies all data w/ google, especially Meta Results Data)"
    msg_10 = "10) FranchiseAlgo: verifies & updates franchise name and type."
    msg_11 = "11) DashboardAlgo: Calculates complex totals and saves results to track over time."
    msg_12 = "12) EmailPredictor: Predicts email for blank emails, with probability score, then verifies bounce."
    msg_break = "\n#{"="*30}\n\n"


    messages = [msg_1, msg_2, msg_3, msg_4, msg_5, msg_6, msg_7, msg_8, msg_9, msg_10, msg_11, msg_12, msg_break]
    messages.each {|msg| puts msg }

    puts msg_1
    puts msg_2
    CsvToolMod::Import.restore_all_backups

    puts msg_3
    Formatter.new.run_all_formatters

    puts msg_4
    VerUrl.new.start_ver_url

    puts msg_5
    TemplateGrabber.new.run_template_grabber

    puts msg_6
    LinkTextGrabber.new.run_link_text_grabber

    puts msg_7
    ActScraper.new.run_act_scraper

    puts msg_8
    ContScraper.new.run_cont_scraper

    puts msg_9
    ApiScraper.new.run_api_scraper

    puts msg_10
    FranchiseAlgo.new.run_franchise_algo

    puts msg_11
    DashboardAlgo.new.run_dashboard_algo

    # puts msg_12
    # ContScraper.new.run_cont_scraper










  end




end
