class CreateUniConts < ActiveRecord::Migration[5.1]
  def change
    create_table :uni_conts do |t|

    # CONTACTS
      t.integer :act_id
      t.integer :cont_id
      t.string :crma
      t.string :crmc
      t.string :cont_sts
      t.string :first_name
      t.string :last_name
      t.string :email

    # JOB_DESCRIPTION
      t.string :job_desc

    # JOB_TITLE
      t.string :job_title

    # Phones
      t.integer :phone_id
      t.string :phone

    # Webs
      t.integer :web_id
      t.string :url_ver_sts
      t.string :url
      t.string :staff_page
      t.string :locations_page

      t.timestamps
    end
  end
end
