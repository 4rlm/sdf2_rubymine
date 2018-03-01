class CreateActWebs < ActiveRecord::Migration[5.1]
  def change
    create_table :act_webs do |t|

      t.references :act, index: true, null: false
      t.references :web, index: true, null: false

      t.timestamps
    end
    add_index :act_webs, [:act_id, :web_id], unique: true
  end
end
