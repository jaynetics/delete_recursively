# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151110173324) do

  create_table "blogs", force: :cascade do |t|
  end

  create_table "boxes", force: :cascade do |t|
    t.integer "pizza_id"
    t.index ["pizza_id"], name: "index_boxes_on_pizza_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "post_id"
    t.index ["post_id"], name: "index_comments_on_post_id"
  end

  create_table "delivery_services", force: :cascade do |t|
  end

  create_table "flavors", force: :cascade do |t|
    t.integer "pizza_id"
    t.index ["pizza_id"], name: "index_flavors_on_pizza_id"
  end

  create_table "houses", force: :cascade do |t|
  end

  create_table "ingredients", force: :cascade do |t|
    t.integer "dish_id"
    t.index ["dish_id"], name: "index_ingredients_on_dish_id"
  end

  create_table "letterboxes", force: :cascade do |t|
    t.integer "renter_id"
    t.index ["renter_id"], name: "index_letterboxes_on_renter_id"
  end

  create_table "letters", force: :cascade do |t|
    t.integer "letterbox_id"
    t.index ["letterbox_id"], name: "index_letters_on_letterbox_id"
  end

  create_table "pizzas", force: :cascade do |t|
    t.integer "delivery_service_id"
    t.integer "programmer_id"
    t.index ["delivery_service_id"], name: "index_pizzas_on_delivery_service_id"
    t.index ["programmer_id"], name: "index_pizzas_on_programmer_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "blog_id"
    t.index ["blog_id"], name: "index_posts_on_blog_id"
  end

  create_table "programmers", force: :cascade do |t|
  end

  create_table "projects", force: :cascade do |t|
    t.string "my_primary_key"
  end

  create_table "rental_agreements", force: :cascade do |t|
    t.integer "renter_id"
    t.integer "house_id"
    t.index ["house_id"], name: "index_rental_agreements_on_house_id"
    t.index ["renter_id"], name: "index_rental_agreements_on_renter_id"
  end

  create_table "renters", force: :cascade do |t|
  end

  create_table "tasks", force: :cascade do |t|
    t.string "my_primary_key"
    t.integer "project_id"
    t.index ["project_id"], name: "index_tasks_on_project_id"
  end

end
