# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'

# require 'iterators/iter_query'
# require 'iter_query'
# require 'final_fwd_url'

class DashboardAlgo
  # include Curler #=> concerns/curler.rb
  # include IterQuery

  def initialize
    puts "\n== Welcome to the DashboardAlgo Class! ==\nCalculates Totals, Stats and Trends of Data."

    welcome_msg = "\n1) This will be pseudocode and instructions for how DashboardAlgo will work.\n2) More directions and pseudocode ... \n3) More directions and pseudocode ... \n\n"

    puts welcome_msg
  end

  def run_dashboard_algo
    # Call: DashboardAlgo.new.run_dashboard_algo
    generate_query
  end


  def generate_query
    puts "Sample query generating for DashboardAlgo"

    # query = Web
    # .select(:id)
    # .where.not(archived: TRUE)
    # .order("updated_at DESC")

    # iterate_query(query) # via IterQuery
  end


end
