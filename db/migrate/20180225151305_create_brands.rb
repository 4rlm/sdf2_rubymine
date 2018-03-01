class CreateBrands < ActiveRecord::Migration[5.1]
  def change
    create_table :brands do |t|

      t.string :brand_name, index: true, unique: true, null: false
      t.string :dealer_type

    end
  end
end
