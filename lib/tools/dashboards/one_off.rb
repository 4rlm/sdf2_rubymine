module OneOff



  ### THIS IS LIGHTER VERSION - ACCIDENTALLY DELETED ActWeb and lost data! - BOTTOM IS HEAVIER VERSION.
  #CALL: OneOff.act_to_web_light
  def self.act_to_web_light
    Act.where.not(url: nil).each do |act|
      web_obj = Web.find_by(url: act.url)
      (act.webs << web_obj if !act.webs.include?(web_obj)) if web_obj.present?
    end
  end

  #
  # def self.act_to_web_light
  #   Web.where(url_sts: 'FWD').each do |web|
  #
  #   end
  # end



  ### THIS IS FOR VERY FIRST TIME TRANSFERING EVERYTHING! - TOP IS LIGHTER VERSION.
  ## Migrates data from Act to Web.  Will later remove from Act.
  # #CALL: OneOff.act_to_web_full
  # def self.act_to_web_full
  #   act_ids = Act.select(:id).where.not(url: nil).pluck(:id)
  #   act_ids.each do |act_id|
  #     act = Act.find(act_id)
  #     web = Web.find_or_create_by(url: act.url)
  #
  #     web.update(url: act.url, url_sts_code: act.url_sts_code, temp_name: act.temp_name, tmp_date: act.tmp_date, gp_date: act.gp_date, page_date: act.page_date, url_date: act.url_date, cs_date: act.cs_date, url_sts: act.url_sts, temp_sts: act.temp_sts, page_sts: act.page_sts, cs_sts: act.cs_sts)
  #
  #
  #     act_conts = act.conts
  #     act_conts.each do |act_cont|
  #       web.conts << act_cont if !web.conts.present?
  #     end
  #
  #
  #     act_links = act.links
  #     act_links.each do |act_link|
  #       web.links << act_link if !web.links.present?
  #     end
  #
  #   end
  # end




end
