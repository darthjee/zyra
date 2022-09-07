# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name
    t.string :email
    t.string :password
    t.string :reference
  end

  create_table :posts, force: true do |t|
    t.integer :user_id
    t.string :name
    t.text :content
  end
end
