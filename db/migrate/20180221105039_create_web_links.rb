class CreateWebLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :web_links do |t|

      t.references :web, index: true, null: false
      t.references :link, index: true, null: false
      
      t.string  :link_sts, index: true
      t.integer :cs_count, default: 0

      t.timestamps
    end
    add_index :web_links, [:web_id, :link_id], unique: true
  end
end
