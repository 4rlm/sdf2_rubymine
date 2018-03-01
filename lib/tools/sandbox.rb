# Note: This is for running one-offs or for testing in isolation.  Not intended to remain here long-term.

#Call: Sandbox.new.method_name
class Sandbox

  #Call: Sandbox.new.clean_zips
  def clean_zips
    @formatter = Formatter.new
    adrs = Adr.where.not(zip: nil)
    adrs = Adr.where("length(zip) = 4") # 1433
    # adrs = Adr.where("length(zip) = 8").count # 0
    # Adr.where("zip LIKE '%-%'").count # 5036

    adrs.each do |adr|
      zip_orig = adr.zip
      zip_formatted = @formatter.format_zip(zip_orig)

      puts "\n==========="
      puts zip_orig
      puts zip_formatted

      adr.update(zip: zip_formatted)
    end







    #CALL: Formatter.new.format_zip(zip)

  end




end
