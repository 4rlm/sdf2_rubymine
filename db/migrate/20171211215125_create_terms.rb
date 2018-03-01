class CreateTerms < ActiveRecord::Migration[5.1]
  def change
    create_table :terms do |t|

      t.string :category
      t.string :sub_category
      t.string :criteria_term
      t.string :response_term
      t.string :mth_name

      t.timestamps
    end
  end
end
