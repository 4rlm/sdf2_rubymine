# require 'csv'
# require 'pry'
# require 'csv_export'
# require 'csv_import'

# %w{csv pry csv_export csv_import}.each { |x| require x }

class CsvTool
  extend ActiveSupport::Concern
  include CsvExport
  include CsvImport
  attr_reader :file_name, :file_path

  def initialize
    @seeds_dir_path = "./db/csv/seeds"
    @backups_dir_path = "./db/csv/backups"
    FileUtils.mkdir_p(@seeds_dir_path)
    FileUtils.mkdir_p(@backups_dir_path)
  end



  ###### SHARED METHODS AMONGST BOTH MODULES ######


  #CALL: CsvTool.new.get_db_table_list
  def get_db_table_list
    Rails.application.eager_load!
    db_table_list = ActiveRecord::Base.descendants.map(&:name)
    removables = ['ApplicationRecord', 'UniAct', 'UniCont', 'UniWeb', 'Delayed::Backend::ActiveRecord::Job']
    removables.each { |table| db_table_list.delete(table) }
    # db_table_list = db_table_list.sort_by(&:length)
    db_table_list = db_table_list.sort
    return db_table_list
  end


  def val_hsh(cols, hsh)
    ## Consider switching hash to keys.
    # cols.map!(&:to_sym)
    # binding.pry
    keys = hsh.keys
    keys.each { |key| hsh.delete(key) if !cols.include?(key) }
    # binding.pry
    # adr_hsh.symbolize_keys
    return hsh
  end


  def parse_csv
    counter = 0
    error_row_numbers = []
    @clean_csv_hashes = []
    @headers = []
    @rows = []

    File.open(@file_path).each do |line|
      begin
        line_1 = line&.gsub(/\s/, ' ')&.strip ## Removes carriage returns and new lines.
        line_2 = force_utf_encoding(line_1) ## Removes non-utf8 chars.

        CSV.parse(line_2) do |row|
          row = row.collect { |x| x.try(:strip) } ## Strips white space from each el in row array.

          if counter > 0
            @clean_csv_hashes << row_to_hsh(row)
            @rows << row
          else
            @headers = row
          end
          counter += 1
        end
      rescue => er
        error_row_numbers << {"#{counter}": "#{er.message}"}
        counter += 1
        next
      end
    end

    error_report(error_row_numbers)
    # return @clean_csv_hashes
  end


  def error_report(error_row_numbers)
    puts "\nCSV data ready to import.\nCSV Errors Found: #{error_row_numbers.length}\nRows containing errors (if any) will be skipped.\nErrors on the lines listed below (if any):"
    error_row_numbers.each_with_index { |hsh, i| puts "#{i+1}) Row #{hsh.keys[0]}: #{hsh.values[0]}." }
  end

  def row_to_hsh(row)
    h = Hash[@headers.zip(row)]
    h.symbolize_keys
  end


  def completion_msg(model, file_name)
    Reporter.db_totals_report
    puts "\n\n== Sleep(2): Completed Import: #{file_name} to #{model} table. ==\n\n"
    sleep(2)
  end

  def force_utf_encoding(text)
    # text = "Ã¥ÃŠÃ¥Â©team auto solutions"
    # text = "Ã¥ÃŠÃ¥ÃŠÃ¥ÃŠour staff"
    clean_text = text.delete("^\u{0000}-\u{007F}")
    clean_text = clean_text.gsub(/\s+/, ' ')

    return clean_text
  end


end
