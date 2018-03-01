%w{mig_uni_act mig_uni_cont mig_uni_web}.each { |x| require x }

class Mig
  # extend ActiveSupport::Concern
  include MigUniAct
  include MigUniCont
  include MigUniWeb
  # include WebMig

  ### To call any of the three UniMig Modules ###
  #Call: Mig.new.migrate_uni_acts
  #Call: Mig.new.migrate_uni_conts
  #Call: Mig.new.migrate_uni_webs

  ### CAREFUL!!! BELOW METHODS BEING USED IN EACH UNI_MIGRATOR MODULE ###

  def initialize
    @formatter = Formatter.new
  end

  ## Used for Tables where only one Attr matters, like Phone.phone
  def save_simp_obj(model, attr_hsh)
    obj = model.classify.constantize.find_or_create_by(attr_hsh)
    #Ex: phone_obj = Phone.find_or_create_by(phone: phone)
    return obj
  end


  ## Used for Tables where we need to first find by one attribute, then save or update several other attributes like Act or Cont.
  def save_comp_obj(model, attr_hsh, obj_hsh)
    obj_hsh.delete_if { |key, value| value.blank? }
    obj = model.classify.constantize.find_by(attr_hsh)
    obj.present? ? update_obj_if_changed(obj_hsh, obj) : obj = model.classify.constantize.create(obj_hsh)
    #Ex: web_obj = Web.find_by(url: url)
    #Ex: web_obj.present? ? update_obj_if_changed(web_hsh, web_obj) : web_obj = Web.create(web_hsh)
    return obj
  end

  def create_obj_parent_assoc(model, obj, parent)
  #Ex: act.phones << phone_obj if !act.phones.include?(phone_obj)
    if model.present? && obj.present? && parent.present?

      begin
        if !parent.send(model.pluralize.to_sym).include?(obj)
          parent.send(model.pluralize.to_sym) << obj
        end
      rescue StandardError => error
        ### duplicate object data, but different id. Can ignore.
        puts "\n\n=== RESCUE ERROR!! ==="
        puts error.class.name
        puts error.message
      end

    end
  end

  def update_obj_if_changed(hsh, obj)
    hsh.delete_if { |k, v| v.nil? }

    if hsh['updated_at']
      hsh.delete('updated_at')
      obj.record_timestamps = false
    end

    updated_attributes = (hsh.values) - (obj.attributes.values)
    obj.update(hsh) if !updated_attributes.empty?
  end


  def val_hsh(cols, hsh)
    ## hsh keys must be strings due to cols being strings too.
    hsh = hsh.stringify_keys
    if cols.present? && hsh.present?
      keys = hsh.keys
      keys.each { |key| hsh.delete(key) if !cols.include?(key) }
      hsh = hsh.symbolize_keys
      return hsh
    end
  end


  #Call: Mig.new.reset_pk_sequence
  def reset_pk_sequence
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end


end
