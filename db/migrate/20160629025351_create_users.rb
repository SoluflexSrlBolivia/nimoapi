class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :firstname
      t.string   :lastname
      t.string   :email, unique: true
      t.string   :gender  #male, female
      t.datetime :birthday
      t.text     :occupation
      t.string   :phone_number
      t.string   :country
      t.string   :subregion
      t.boolean  :deleted, default: false
      t.boolean  :notification, default: true
      t.string   :password_digest
      t.string   :remember_digest
      t.boolean  :admin, default: false
      t.string   :activation_digest
      t.boolean  :activated, default: false
      t.datetime :activated_at
      t.string   :reset_digest
      t.datetime :reset_sent_at
      t.string   :authentication_token

      t.timestamps null: false
    end
  end
end
