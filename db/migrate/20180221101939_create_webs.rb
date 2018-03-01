class CreateWebs < ActiveRecord::Migration[5.1]
  def change
    create_table :webs do |t|

      t.string  :url, index: true, unique: true, null: false
      # t.string  :url, index: true, unique: true, null: true
      t.string  :url_sts_code, index: true
      t.boolean :cop, default: false
      t.string  :temp_name, index: true

      ## Statuses
      t.string  :url_sts, index: true
      t.string  :temp_sts, index: true
      t.string  :page_sts, index: true
      t.string  :cs_sts, index: true
      t.string  :brand_sts, index: true
      t.integer :timeout, index: false, default: 0

      ## Dates
      t.datetime :url_date, index: true
      t.datetime :tmp_date, index: true
      t.datetime :page_date, index: true
      t.datetime :cs_date, index: true
      t.datetime :brand_date, index: true

      t.integer  :fwd_url
      t.datetime :web_changed, index: true
      t.datetime :wx_date, index: true

      t.timestamps
    end
  end
end
