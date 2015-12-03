###
class CreateTestTables < ActiveRecord::Migration
  def change
    create_table :blogs

    create_table :posts do |t|
      t.belongs_to :blog
    end

    create_table :comments do |t|
      t.belongs_to :post
    end

    ########

    create_table :delivery_services

    create_table :programmers

    create_table :pizzas do |t|
      t.belongs_to :delivery_service
      t.belongs_to :programmer
    end

    create_table :boxes do |t|
      t.belongs_to :pizza
    end

    create_table :ingredients do |t|
      t.belongs_to :dish
    end

    ########

    create_table :projects do |t|
      t.string :my_primary_key
    end

    create_table :tasks do |t|
      t.string :my_primary_key
      t.belongs_to :project
    end
  end
end
