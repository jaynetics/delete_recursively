ActiveRecord::Schema.define(version: 20151110173325) do
  create_table 'blogs', force: :cascade do |t|
  end

  create_table 'posts', force: :cascade do |t|
    t.integer 'blog_id'
  end

  create_table 'comments', force: :cascade do |t|
    t.integer 'post_id'
  end

  ######

  create_table 'delivery_services', force: :cascade do |t|
  end

  create_table 'programmers', force: :cascade do |t|
  end

  create_table 'pizzas', force: :cascade do |t|
    t.integer 'delivery_service_id'
    t.integer 'programmer_id'
  end

  create_table 'boxes', force: :cascade do |t|
    t.integer 'pizza_id'
  end

  create_table 'flavors', force: :cascade do |t|
    t.integer 'pizza_id'
  end

  create_table 'ingredients', force: :cascade do |t|
    t.integer 'dish_id'
  end

  ######

  create_table 'projects', force: :cascade do |t|
    t.string 'my_primary_key'
  end

  create_table 'tasks', force: :cascade do |t|
    t.string 'my_primary_key'
    t.integer 'project_id'
  end

  ######

  create_table 'renters', force: :cascade do |t|
  end

  create_table 'houses', force: :cascade do |t|
  end

  create_table 'rental_agreements', force: :cascade do |t|
    t.integer 'renter_id'
    t.integer 'house_id'
  end

  create_table 'letterboxes', force: :cascade do |t|
    t.integer 'renter_id'
  end

  create_table 'letters', force: :cascade do |t|
    t.integer 'letterbox_id'
  end
end
