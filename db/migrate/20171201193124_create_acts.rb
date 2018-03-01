class CreateActs < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'
    create_table :acts do |t|

      ## Account Name
      t.citext  :act_name, index: true, unique: true, allow_nil: true
      t.string  :gp_id, index: true, unique: true, allow_nil: true
      t.string  :gp_sts, index: true
      t.datetime :gp_date, index: true
      t.string  :gp_indus, index: true
      t.string  :lat
      t.string  :lon

      ## Address Info
      t.citext  :street, index: true
      t.citext  :city, index: true
      t.string  :state, index: true
      t.string  :zip, index: true
      t.citext  :full_address, index: true
      t.string  :phone, index: true

      t.datetime :adr_changed, index: true
      t.datetime :act_changed, index: true
      t.datetime :ax_date, index: true

      t.timestamps
    end
  end
end
