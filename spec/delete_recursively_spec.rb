
require 'spec_helper'

describe DeleteRecursively do
  describe 'dependent: :delete_recursively' do
    it 'deletes all dependent records when a record is destroyed' do
      blog = Blog.create!
      posts = [blog.posts.create!,
               blog.posts.create!]
      comments = [posts[0].comments.create!,
                  posts[1].comments.create!]

      blog.destroy!

      expect(Blog.count(id: blog.id)).to eq(0)
      expect(Post.count(id: posts.map(&:id))).to eq(0)
      expect(Comment.count(id: comments.map(&:id))).to eq(0)
    end

    it 'uses #destroy to delete records associated as dependent: :destroy' do
      blog = Blog.create!
      post = blog.posts.create!
      3.times { post.comments.create! }

      expect(Rails.logger)
        .to receive(:info)
        .with('Comment destroy callback!')
        .exactly(3).times

      blog.destroy!
    end

    it 'works on has_one: associations' do
      delivery_service = DeliveryService.create!
      pizza = delivery_service.pizzas.new
      pizza.box = Box.create!
      pizza.save!

      delivery_service.destroy!

      expect(DeliveryService.count(id: delivery_service.id)).to eq(0)
      expect(Pizza.count(id: pizza.id)).to eq(0)
      expect(Box.count(id: pizza.box.id)).to eq(0)
    end

    it 'works on belongs_to: associations' do
      delivery_service = DeliveryService.create!
      pizza = delivery_service.pizzas.new
      pizza.programmer = Programmer.create!
      pizza.save!

      delivery_service.destroy!

      expect(DeliveryService.count(id: delivery_service.id)).to eq(0)
      expect(Pizza.count(id: pizza.id)).to eq(0)
      expect(Programmer.count(id: pizza.programmer.id)).to eq(0)
    end

    it 'works with a custom :class_name' do
      delivery_service = DeliveryService.create!
      pizza = delivery_service.pizzas.create!
      toppings = [pizza.toppings.create!,
                  pizza.toppings.create!]

      delivery_service.destroy!

      expect(DeliveryService.count(id: delivery_service.id)).to eq(0)
      expect(Pizza.count(id: pizza.id)).to eq(0)
      expect(Ingredient.count(id: toppings.map(&:id))).to eq(0)
    end

    it 'works on records with a custom :primary_key' do
      project = Project.create!(my_primary_key: 'project_1')
      tasks = [project.tasks.create!(my_primary_key: 'task_1'),
               project.tasks.create!(my_primary_key: 'task_2')]

      project.destroy!

      expect(Project.count(my_primary_key: project.my_primary_key)).to eq(0)
      expect(Task.count(my_primary_key: tasks.map(&:my_primary_key))).to eq(0)
    end
  end

  describe '::all' do
    it 'deletes all class records and all records of dependent classes' do
      2.times { Blog.create! && Post.create! && Comment.create! }

      DeleteRecursively.all(Blog)

      expect(Blog.count).to eq(0)
      expect(Post.count).to eq(0)
      expect(Comment.count).to eq(0)
    end

    it 'works with a custom :class_name' do
      2.times { DeliveryService.create! && Pizza.create! && Ingredient.create! }

      DeleteRecursively.all(DeliveryService)

      expect(DeliveryService.count).to eq(0)
      expect(Pizza.count).to eq(0)
      expect(Ingredient.count).to eq(0)
    end

    it 'works on records with a custom :primary_key' do
      2.times { Project.create! && Task.create! }

      DeleteRecursively.all(Project)

      expect(Project.count).to eq(0)
      expect(Task.count).to eq(0)
    end
  end
end
