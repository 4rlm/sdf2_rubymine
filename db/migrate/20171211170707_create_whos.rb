class CreateWhos < ActiveRecord::Migration[5.1]
  def change
    create_table :whos do |t|
      
      t.string :ip
      t.string :server1
      t.string :server2
      t.string :registrant_name
      t.string :registrant_email

      t.timestamps
    end
  end
end
