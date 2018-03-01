class CreateUniActs < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'
    create_table :uni_acts do |t|

      ## Act Table
      t.citext  :act_name
      t.string  :gp_id
      t.string  :gp_sts
      t.datetime :gp_date
      t.string  :gp_indus
      t.string  :lat
      t.string  :lon
      t.citext  :street
      t.citext  :city
      t.string  :state
      t.string  :zip
      t.citext  :full_address
      t.string  :phone

      ## Link Table
      t.citext  :staff_link
      t.citext  :staff_text

      ## Web Table
      t.string  :url1
      t.string  :url2
      t.string  :brand1
      t.string  :brand2
      t.string  :brand3
      t.string  :brand4
      t.string  :brand5
      t.string  :brand6
      t.string  :url_sts_code
      t.boolean :cop
      t.string  :temp_name
      t.string  :url_sts
      t.string  :temp_sts
      t.string  :page_sts
      t.string  :cs_sts
      t.string  :brand_sts
      t.integer :timeout
      t.datetime :url_date
      t.datetime :tmp_date
      t.datetime :page_date
      t.datetime :cs_date
      t.datetime :brand_date

      ## Brand Table
      t.string :brand_name
      t.string :dealer_type

      #### MIGRATES TO: WHO TABLE ####
      t.string  :ip
      t.string  :server1
      t.string  :server2
      t.string  :registrant_name
      t.string  :registrant_email
      #####################################

      t.timestamps
    end
  end
end
