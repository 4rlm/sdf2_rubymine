#CALL: ContScraper.new.start_cont_scraper

class CsHelper # Contact Scraper Helper Method
  include FormatPhone
  # format_phone(phone)

  def initialize
    @formatter = Formatter.new
  end


  def extract_noko(raw_css)
    if raw_css.present?
      formatted_css = []
      raw_css.map do |inner|
        nodes = []
        # inner.traverse {|node| nodes << node.text }
        inner.traverse {|node| nodes << node.text }
        nodes.reject!(&:blank?)
        nodes.uniq!

        nodes = nodes.join(", ").split(' - ').join(", ").split(', ')
        nodes.map! do |nod|
          # nod = nod.delete("^\u{0000}-\u{007F}")&.strip
          nod = nod.gsub("^\u{0000}-\u{007F}", " ")&.strip

          if nod.present?
            nod_nums = nod.scan(/[0-9]/)
            nod = nil if nod_nums.any? && (nod_nums.count > 11 || nod_nums.count < 10)
          end

          nod = nil if (nod.length < 3 || nod.length > 30) if nod
          nod = nil if junk_detector(nod) if nod
          nod
        end

        nodes.map! {|nod| nod&.strip}
        nodes.reject!(&:blank?)
        nodes.uniq!
        formatted_css << nodes
      end

      formatted_css.reject!(&:blank?)
      return formatted_css
    end
  end

  #CALL: ContScraper.new.start_cont_scraper
  def consolidate_cs_hsh_arr(ez_staffs)
    cs_hsh_arr = standard_scraper(ez_staffs)
    cs_hsh_arr.map! { |temp_cs_hsh| temp_cs_hsh.sort.to_h }

    cs_hsh_arr.delete_if(&:empty?)&.uniq!
    cs_hsh_arr = prep_create_staffer(cs_hsh_arr) if cs_hsh_arr.any?
    return cs_hsh_arr
  end


  def standard_scraper(staff_arrs)
    cs_hsh_arr = []

    if staff_arrs.any?
      staff_arrs.each do |staff_arr|
        staff = staff_arr.join('')
        ## Structured to prevent job_desc going to full_name
        staff_hash = {}
        # staff_arr = staff.split(", ")
        staff_arr.each do |staff_text|
          if !staff_text&.scan(/[0-9]/).any? && staff_text.length < 30 && staff_text.split(' ').count < 6 && !staff_text.include?('@')
            job_desc = job_detector(staff_text)
            full_name = name_detector(staff_text)

            if job_desc.present? && !staff_hash[:job_desc]&.present?
              staff_hash[:job_desc] = job_desc
            elsif full_name.present? && !staff_hash[:full_name]&.present? && !job_desc.present?
              staff_hash[:full_name] = full_name
            end

          end

          phone_hsh = phone_detector(staff_text)
          if phone_hsh.present?
            phone = phone_hsh[:phone]
            phone = @formatter.validate_phone(phone) if phone.present?
            staff_hash[:phone] = phone
          end
        end

        ## Get email
        if staff.include?('@') && !staff_hash[:email]&.present?
          regex = Regexp.new("[a-z]+[@][a-z]+[.][a-z]+")
          email_reg = regex.match(staff)
          staff_hash[:email] = email_reg.to_s if email_reg
        end

        cs_hsh_arr << staff_hash
      end
    end
    return cs_hsh_arr
  end

  ##################################
  ## WORKS VERY WELL, BUT NOT NEEDED NOW
  # def force_utf_encoding(text)
  #   if text.present?
  #     step1 = text.delete("^\u{0000}-\u{007F}")&.strip
  #     step1.gsub!('Phone', ',')
  #     step1.gsub!('phone', ',')
  #     step2 = step1&.split(',')
  #     step3 = step2&.map! {|str| str.split('  ') }
  #     step4 = step3&.flatten
  #     step5 = step4&.reject(&:blank?)
  #     return step5
  #   end
  # end
  ##################################

  def job_detector(str)
    return nil if !str.present? || str&.scan(/[0-9]/).any? || str.length > 30 || str.split(' ').count > 5 || str.include?('@')

    jobs = %w(account admin advis agent assist associ attend bdc brand busin car cashier center ceo certified chief clerk consultant coordinat cto customer dealer detail develop direct driver engineer estimator executive finan fleet general gm intern inventory leasing license mainten manage market new office online operat own part pres principal professional receiv reception recruit represent sales scheduler service shipping shop shuttle special superv support tech trainer transmission transportation ucm used varia vice vp warranty write)

    parts = str.split(' ')
    clean_str = []
    parts.each do |part|
      part = part.tr('^-A-Za-z', ' ')
      clean_str << part if part&.length > 2
    end
    str = clean_str.join(' ')

    down_str = str.downcase
    res = jobs.find { |job| down_str.include?(job) }
    return str if res.present?
  end


  #CALL: ContScraper.new.start_cont_scraper
  def name_detector(str)
    return nil if str&.scan(/[0-9]/).any? || str.length > 30 || str.split(' ').count > 5 || str.include?('@')
    str.gsub!(/\W/," ")
    parts = str.split(" ")
    name_reg = Regexp.new("[@./0-9]")
    return nil if str.scan(name_reg).any? || (parts.length > 3 || parts.length < 2)

    clean_str = []
    parts.each do |part|
      part = part.tr('^-A-Za-z', " ")
      clean_str << part if part&.length > 2
    end

    if clean_str.length > 1 && clean_str.length < 3
      str = clean_str.join(' ')
      return str
    end

    return nil
  end


  def phone_detector(str)
    return nil if str.length > 30
    str = str.split('ext')&.first&.strip
    return nil if !str&.scan(/[0-9]/)&.length.in?([10, 11])

    phone = @formatter.format_phone(str)
    phone.present? ? {phone: phone, str: str} : nil
  end


  def junk_detector(str)
    junks = %w(# = [ ] : ; @ ! ? { } about account address analyt apply back box call change chat check choice click color comment contact content country custom direction display email finan float font form give google great ground hide hover hour info input load margin meet more name nav none our phone policy priva question quick quote rate ready saving size src staff strict tab title today type use width employ dealer contact phone mail make inquir first last name zip code have question search blog popular tag open close mond tues wedn thur frid saturd sunday model year battery jump tire roadside access reward play gof family outside work star showroom link social media youtube twitter facebook critic review rating inventory holiday save saving money shop yelp page yellow blue red green white black pink brown qualif quality bing local friend lounge equip wifi shop motor keep site map acadia amount any approv ats benz blade category commercial compare coupe cts current disclos escalade esv found limit message offer royal sedan suv text truck vehicle view wiper written)
    junks += [' our', ' me ', ' by ', ' an ', ' and ', ' a ', ' with ', ' the ', ' for ', ' from ', ' to ', ' come ', ' now ', ' your ']

    down_str = str.downcase
    junks.each { |junk| return true if down_str.include?(junk) }
    return false
    # junks.each { |junk| return [str] if down_str.include?(junk) }
    # return []
  end


  #CALL: ContScraper.new.start_cont_scraper
  def prep_create_staffer(cs_hsh_arr)

    cs_hsh_arr.each do |staff_hash|
      # Clean & Divide full name
      if staff_hash[:full_name]
        name_parts = staff_hash[:full_name].split(" ")
        full_name = name_parts.reject {|x| x.first == x.last}.join(' ')
        staff_hash[:full_name] = squeeze_and_strip(full_name)
      end

      # Split full_name into first_name and last_name
      if staff_hash[:full_name]
        name_parts = staff_hash[:full_name].split(" ").each { |name| name&.strip&.capitalize! }
        staff_hash[:first_name] = name_parts&.first&.strip
        staff_hash[:last_name] = name_parts&.last&.strip
        staff_hash[:full_name] = name_parts.join(' ')
      elsif staff_hash[:first_name] && staff_hash[:last_name]
        staff_hash[:first_name] = staff_hash[:first_name]&.strip&.capitalize
        staff_hash[:last_name] = staff_hash[:last_name]&.strip&.capitalize
        staff_hash[:full_name] = "#{staff_hash[:first_name]} #{staff_hash[:last_name]}"
      end

      # Clean email address
      if email = staff_hash[:email]
        email.gsub!(/mailto:/, '') if email.include?("mailto:")
        staff_hash[:email] = squeeze_and_strip(email)
      end

      # Clean Job Desc
      job_desc = staff_hash[:job_desc]
      if job_desc.present?
        job_desc.gsub!('Español', '')
        job_desc = nil if job_desc.scan(/[0-9]/)&.any?
        staff_hash[:job_title] = get_job_title(job_desc)
        job_desc = squeeze_and_strip(job_desc)
        staff_hash[:job_desc] = job_desc
      end

      # Clean Phone
      phone = format_phone(staff_hash[:phone]&.strip)
      phone = @formatter.validate_phone(phone) if phone.present?
      phone = nil if phone && (phone[1] == '0' || phone[1] == '1')
      phone = nil if phone&.scan(/[A-Za-z]/)&.any?
      staff_hash[:phone] = phone

      ## Remove Blanks
      staff_hash.delete_if { |key, value| value.blank? } if !staff_hash.empty?
    end

    cs_hsh_arr = remove_invalid_cs_hsh(cs_hsh_arr)
    cs_hsh_arr.delete_if(&:empty?)&.uniq!
    return cs_hsh_arr
  end

  #CALL: ContScraper.new.start_cont_scraper
  def squeeze_and_strip(str)
    if str.present?
      str.squeeze!(' ')
      str.strip!
      return str
    end
  end


  def get_job_title(job_desc)
    if job_desc.present?
      job_desc = job_desc.gsub('-', ' ')
      job_desc = job_desc.gsub('/', ' ')
      job_desc = job_desc.gsub('.', ' ')
      job_desc = job_desc.split(' ').map(&:capitalize).join(' ')

      swaps = {Assisant: 'Asst', Person: 'Rep', Consultant: 'Rep', Receivable: 'Payable', Vehicle: 'Car', 'Pre-Owned' => 'Used', Manager: 'Mgr', Brand: 'Sales', Technologist: 'Technician', Exchange: 'Sales', Tech: 'Technician', Agent: 'Rep', Advisor: 'Rep', Representative: 'Rep', Genius: 'Sales Rep', 'Business Development Center' => 'BDC', 'Business Development' => 'BDC', Operator: 'Rep', Coordinator: 'Rep', Mechanic: 'Technician', Associate: 'Rep', Product: 'Sales', Specialist: 'Rep', 'Chief Operations Officer' => 'COO', Truck: 'Sales', Care: 'Service', Client: 'Sales', Appointment: 'BDC', Success: 'Service', Detail: 'Detailer', Delivery: 'Driver', Commerce: 'E-Commerce', Guest: 'Customer', Services: 'Service', Internet: 'BDC', Leasing: 'Sales', 'Pre Owned' => 'Used Car', HR: 'Human Resources', Management: 'Mgr', 'Owner President' => 'Owner', 'General Counsel' => 'Legal', 'Client Advisor' => 'Sales Rep', 'Team Leader' => 'Mgr', 'Delivery Coordinator' => 'Driver', Merchandiser: 'Rep', 'Call Center' => 'BDC', Controller: 'Fixed Operations', Warranty: 'Warranty Rep', Director: 'Dir', Marketing: 'Mktg', Supervisor: 'Supr', Administrator: 'Admin'}.stringify_keys
      job_desc = job_desc&.gsub(Regexp.union(swaps.keys), swaps)

      tops = %w(Asst Vice President General Executive)
      roles = %w(Used New Car Sales Accessories Accounting Accounts E-Commerce Administration Customer BDC Billing Body Brand Cashier CFO COO Collision Detailer Digital Finance Fleet Mktg Fixed Variable IT Inventory Operations Office Parts Payable Service Shop Technician Technology Title Warranty Human Resources Comptroller Legal Receptionist)
      roles += []
      levels = %w(Apprentice Clerk Dir Mgr Owner Principal Rep Secretary Supr Admin)

      title_arr = []
      tops.each { |top| title_arr << top if job_desc.include?(top) }
      roles.each { |role| title_arr << role if job_desc.include?(role) }
      levels.each { |level| title_arr << level if job_desc.include?(level) }
      job_title = title_arr.uniq.join(' ')

      job_title&.gsub!('Used Car Sales Mgr', 'Used Car Mgr')
      job_title&.gsub!('New Car Sales Mgr', 'New Car Mgr')
      job_title&.gsub!('Sales BDC', 'BDC')
      # job_title&.gsub!('Sales BDC Mgr', 'BDC Mgr')
      job_title&.gsub!('Sales Mktg Mgr', 'Mktg Mgr')
      job_title&.gsub!('Mktg Technician Dir', 'Mktg Dir')
      job_title&.gsub!('Used Car Sales Rep', 'Sales Rep')
      job_title&.gsub!('Sales Receptionist', 'Receptionist')
      job_title&.gsub!('Sales Rep Mgr', 'Sales Mgr')
      job_title&.gsub!('Sales Body', 'Body')
      job_title&.gsub!('Service Receptionist', 'Receptionist')
      job_title&.gsub!('Sales Finance Mgr', 'Sales Mgr')
      job_title&.gsub!('BDC Service', 'BDC')
      job_title&.gsub!('Accounting Clerk', 'Accounting')

      return job_title
    end
  end


  def remove_invalid_cs_hsh(cs_hsh_arr)
    cs_hsh_arr.delete_if { |hsh| !hsh[:full_name].present? }.uniq! if cs_hsh_arr.any?
    cs_hsh_arr.delete_if { |hsh| !hsh[:job_desc].present? }.uniq! if cs_hsh_arr.any?
    return cs_hsh_arr
  end

  def email_cleaner(str)
    str = str&.downcase
    str ? str.gsub(/^mailto:/, '') : str
  end

  # def include_neg(str)
  #   negs = %w(: . @ ! ? address call change chat choice contact country custom direction display give great hide hour float load none policy privacy quick quote rate ready saving src strict today use)
  #   negs.each do |neg|
  #     return true if str.include?(neg)
  #   end
  #   return false
  # end

end
