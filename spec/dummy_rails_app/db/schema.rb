# encoding: UTF-8
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
  end

  create_table "comments", force: :cascade do |t|
    t.integer "post_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.integer "dish_id"
  end

  create_table "pizzas", force: :cascade do |t|
    t.integer "programmer_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "blog_id"
  end

  create_table "programmers", force: :cascade do |t|
  end

  create_table "projects", force: :cascade do |t|
    t.string "my_primary_key"
  end

  create_table "tasks", force: :cascade do |t|
    t.string  "my_primary_key"
    t.integer "project_id"
  end

end
