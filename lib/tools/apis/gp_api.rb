# #######################################
# # CALL: Formatter.new.format_act_name('act_name')
# # CALL: GpApi.new.welcome_gp
# # CALL: GpApi.new.welcome2
# #######################################
#
#
# %w{gp_run}.each { |x| require x }
#
# class GpApi
#   include GpRun
#
#   def initialize
#     # @client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
#     @client = GooglePlaces::Client.new('AIzaSyDX5Sn2mNT1vPh_MyMnNOH5YL4cIWaB3s4')
#     @formatter = Formatter.new
#   end
#
# end
