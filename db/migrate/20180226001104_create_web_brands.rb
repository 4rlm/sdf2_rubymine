class CreateWebBrands < ActiveRecord::Migration[5.1]
  def change
    create_table :web_brands do |t|

      t.references :web, index: true, null: false
      t.references :brand, index: true, null: false

      t.timestamps
    end
    add_index :web_brands, [:web_id, :brand_id], unique: true
  end
end
