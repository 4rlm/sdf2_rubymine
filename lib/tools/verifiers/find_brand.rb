#CALL: FindBrand.new.start_find_brand

class FindBrand

  def initialize
    @bts = BrandTerm.all
    @brands = Brand.all
    @cut_off = 24.hour.ago
  end


  def get_query
    query = Web.select(:id)
      .where(url_sts: 'Valid', brand_sts: ['Valid', nil])
      .where('brand_date < ? OR brand_date IS NULL', @cut_off)
      .order("id ASC").pluck(:id)

    puts "\n\nQuery Count: #{query.count}"
    sleep(1)
    # binding.pry
    return query
  end


  def start_find_brand
    get_query.each { |id| template_starter(id) }
  end


  def template_starter(id)
    web = Web.find(id)
    url = web.url
    # web.brands.destroy_all
    update_hsh = { brand_sts: nil, brand_date: Time.now }

    brands = []
    url = web.url
    host = URI(url)&.host if url.present?
    names = web.acts&.map {|act| act&.act_name&.downcase&.split(' ')}
    host&.include?('www') ? names << host&.split('.')[1] : names << host&.split(' ')
    names.flatten!
    names.reject!(&:blank?)

    if names.present?
      names.each do |act_name|
        @bts.each do |bt|
          brands << bt.brand_name if act_name.include?(bt.brand_term)
        end
      end

      brand_objs = brands.uniq.map do |brand|
        @brands.where(brand_name: brand)
      end

      if brand_objs.any?
        brand_objs.each do |brand_obj|
          web.brands << brand_obj if !web.brands.include?(brand_obj)
        end
        update_hsh[:brand_sts] = 'Valid'
      end
    end

    web.update(update_hsh)

    # puts names.uniq
    # puts "----------"
    # puts brands.uniq
    # binding.pry
  end


end

#CALL: FindBrand.new.start_find_brand
