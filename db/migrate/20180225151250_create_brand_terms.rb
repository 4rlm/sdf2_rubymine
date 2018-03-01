class CreateBrandTerms < ActiveRecord::Migration[5.1]
  def change
    create_table :brand_terms do |t|

      t.string :brand_term, index: true, unique: true, null: false
      t.string :brand_name

    end
  end
end
