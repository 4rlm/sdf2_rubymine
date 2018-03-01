# #CALL: GpAct.new.start_gp_act
# ######### Delayed Job #########
# # $ rake jobs:clear
#
# require 'iter_query'
#
# class GpAct
#   include IterQuery
#
#   def initialize
#     @dj_on = false
#     @dj_count_limit = 0
#     @dj_workers = 4
#     @obj_in_grp = 40
#     @dj_refresh_interval = 10
#     @count = 0
#     @cut_off = 5.days.ago
#     # @prior_query_count = 0
#     # @make_urlx = FALSE
#     @gp = GpApi.new
#     @formatter = Formatter.new
#     @mig = Mig.new
#   end
#
#   def get_query
#     ## Nil Query
#     query = Act.select(:id).where(actx: FALSE, gp_sts: nil, gp_id: nil).order("id ASC").pluck(:id)
#     query = Act.select(:id).where(gp_id: nil).where('gp_date < ? OR gp_date IS NULL', @cut_off).order("id ASC").pluck(:id) if !query.present?
#
#     puts query.count
#     sleep(1)
#
#
#
#     ## Valid Sts Query ##
#     query = Act.select(:id).where(actx: FALSE, gp_sts: 'Valid').where('gp_date < ? OR gp_date IS NULL', @cut_off).order("id ASC").pluck(:id) if !query.present?
#
#     print_query_stats(query)
#     sleep(1)
#     return query
#   end
#
#   def print_query_stats(query)
#     puts "\n\n===================="
#     puts "@dj_refresh_interval: #{@dj_refresh_interval}\n\n"
#     puts "\n\nQuery Count: #{query.count}"
#   end
#
#   def start_gp_act
#     query = get_query
#     while query.any?
#       setup_iterator(query)
#       query = get_query
#       break if !query.any?
#     end
#   end
#
#   def setup_iterator(query)
#     @query_count = query.count
#     (@query_count & @query_count > @obj_in_grp) ? @group_count = (@query_count / @obj_in_grp) : @group_count = 2
#     @dj_on ? iterate_query(query) : query.each { |id| template_starter(id) }
#   end
#
#   def template_starter(id)
#     cur_act_obj = Act.find(id)
#     act_name = cur_act_obj.act_name
#     orig_act_name = act_name
#     city = cur_act_obj.city
#     state = cur_act_obj.state
#     url = cur_act_obj.url
#
#     ## Remove Undesirable Words from Act Name before sending to Goog ##
#     invalid_list = %w(service services contract parts collision repairs repair credit loan department dept and safety safe equipment equip body shop wash detailing detail finance financial mobile rv motorsports mobility)
#
#     inval_hsh = @formatter.remove_invalids(act_name, invalid_list)
#     act_name = inval_hsh[:act_name]
#
#     ### GET GOOG RESULTS ###
#     if city && state
#       act_name = "#{act_name} in #{city}, #{state}"
#     elsif city
#       act_name = "#{act_name} in #{city}"
#     elsif state
#       act_name = "#{act_name} in #{state}"
#     end
#
#     gp_hsh = @gp.get_spot(act_name, url)
#     update_db(cur_act_obj, gp_hsh)
#   end
#
#
#   #CALL: GpAct.new.start_gp_act
#   def update_db(cur_act_obj, gp_hsh)
#     act_name = cur_act_obj.act_name
#     cur_act_name = act_name
#     url = cur_act_obj.url
#
#     if gp_hsh&.values&.compact&.present?
#       ## Destroys acts based on duplicate gp_id.
#       if !cur_act_obj.gp_id.present?
#         objs = [Act.find_by(gp_id: gp_hsh[:gp_id])].compact
#         if objs.any?
#           objs << cur_act_obj
#           objs = objs.sort_by(&:id)
#           cur_act_obj = objs.first
#           objs[1..-1].each {|act| act.destroy}
#         end
#       end
#       # valid_name = destroy_invalid_act_names(cur_act_obj, gp_hsh[:act_name], gp_hsh[:url])
#       # return if !valid_name
#     else
#       gp_hsh = {gp_sts: 'Invalid', gp_date: Time.now}
#     end
#
#     cur_act_obj.update(gp_hsh)
#
#     # if gp_hsh&.values&.compact&.present?
#     #   if !cur_act_obj.gp_id.present?
#     #     objs = [Act.find_by(gp_id: gp_hsh[:gp_id])].compact
#     #     if objs.any?
#     #       objs << cur_act_obj
#     #       objs = objs.sort_by(&:id)
#     #       cur_act_obj = objs.first
#     #       objs[1..-1].each {|act| act.destroy}
#     #     end
#     #   end
#     #   cur_act_obj.update(gp_hsh)
#     # else
#     #   cur_act_obj.update(gp_sts: 'Invalid', gp_date: Time.now)
#     # end
#   end
#
#   # CALL: GpAct.new.runner_to_destroy
#   # def runner_to_destroy
#   #   acts = Act.where(gp_sts: 'Valid').where.not(url: nil).each do |act|
#   #     valid_name = destroy_invalid_act_names(act, act.act_name, act.url)
#   #   end
#   # end
#
#   # def destroy_invalid_act_names(act_obj, act_name, url)
#     ## Destroys acts based on invalid act_name or url
#     # invalid_act_names = ['alarm', 'audio', ' tow ', 'contract', 'parts', 'collisi', 'credit', 'equip', 'body ', 'detail', 'finan', ' loan', 'mobile home', 'motorsport', 'system', 'repair', ' rv ', 'safe', ' wash ']
#     # invalid_act_names += ['insur', ' bank', 'home ', ' auction', ' oil ', 'lube', 'quick', 'express ', 'extreme', 'speed' ]
#
#     # invalid_act_names = %w(finan alarm credit mobility mobilehome repair motorsport insur auction lube quick tire atv 4x4 harley)
#     # invalid_act_names = %w(mobility mobilehome motorsport insur auction tire atv 4x4)
#     # invalid_act_names = %w(mobility mobilehome motorsport insur atv 4x4)
#
#
#
#     # act_name = " #{act_name&.downcase} " if act_name.present?
#     # url = " #{url&.downcase} " if url.present?
#
#     # invalid_act_names.each do |inval|
#     #   # if act_name&.include?(inval) || url&.include?(inval)
#     #   if url&.include?(inval)
#     #     puts "\n\n=======\ninval: #{inval}"
#     #     puts "url: #{url}"
#     #     puts "act_name: #{act_name}"
#     #     # binding.pry
#     #
#     #     act_obj.destroy
#     #     return false ## not valid
#     #   end
#     # end
#
#     # return true ## valid
#   # end
#
#
#
# end
