class CreateLinks < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'
    create_table :links do |t|

      t.citext  :staff_link, null: false
      t.citext  :staff_text, null: true

    end
    add_index :links, [:staff_link, :staff_text], unique: true
  end
end
