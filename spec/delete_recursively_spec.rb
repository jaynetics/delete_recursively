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

      expect(Blog.where(id: blog.id).count).to eq(0)
      expect(Post.where(id: posts.map(&:id)).count).to eq(0)
      expect(Comment.where(id: comments.map(&:id)).count).to eq(0)
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

      expect(DeliveryService.where(id: delivery_service.id).count).to eq(0)
      expect(Pizza.where(id: pizza.id).count).to eq(0)
      expect(Box.where(id: pizza.box.id).count).to eq(0)
    end

    it 'works on has_many: :through associations' do
      house = House.create!
      renters = [house.renters.create!,
                 house.renters.create!]
      letterboxes = [renters.first.letterboxes.create!,
                     renters.first.letterboxes.create!,
                     renters.last.letterboxes.create!,
                     renters.last.letterboxes.create!]

      house.destroy!

      expect(House.where(id: house.id).count).to eq(0)
      expect(Renter.where(id: renters.map(&:id)).count).to eq(0)
      expect(Letterbox.where(id: letterboxes.map(&:id)).count).to eq(0)
    end

    it 'deletes sub-associations with dependent: :delete, but none below those' do
      house = House.create!
      renters = [house.renters.create!,
                 house.renters.create!]
      letterboxes = [renters.first.letterboxes.create!,
                     renters.first.letterboxes.create!,
                     renters.last.letterboxes.create!,
                     renters.last.letterboxes.create!]
      letters = [letterboxes.first.letters.create!,
                 letterboxes.first.letters.create!,
                 letterboxes.last.letters.create!]

      house.destroy!

      expect(House.where(id: house.id).count).to eq(0)
      expect(Renter.where(id: renters.map(&:id)).count).to eq(0)
      expect(Letterbox.where(id: letterboxes.map(&:id)).count).to eq(0)
      expect(Letter.where(id: letters.map(&:id)).count).to eq(3)
    end

    it 'does not delete records without a dependent option' do
      delivery_service = DeliveryService.create!
      pizza = delivery_service.pizzas.new
      pizza.programmer = Programmer.create!
      pizza.save!

      flavor = pizza.flavors.create!

      delivery_service.destroy!

      expect(Flavor.where(id: flavor.id).count).to eq(1)
    end

    # belongs_to is the only association type that needs a unique handling if it
    # is present on the first destroyed record (the callee or "point of entry"),
    # and thus the only type that needs two different tests.

    it 'works on belongs_to: associations of the callee' do
      pizza = Pizza.new
      pizza.programmer = Programmer.create!
      pizza.save!

      pizza.destroy!

      expect(Pizza.where(id: pizza.id).count).to eq(0)
      expect(Programmer.where(id: pizza.programmer.id).count).to eq(0)
    end

    it 'works on belongs_to: associations further down the chain' do
      delivery_service = DeliveryService.create!
      pizza = delivery_service.pizzas.new
      pizza.programmer = Programmer.create!
      pizza.save!

      delivery_service.destroy!

      expect(DeliveryService.where(id: delivery_service.id).count).to eq(0)
      expect(Pizza.where(id: pizza.id).count).to eq(0)
      expect(Programmer.where(id: pizza.programmer.id).count).to eq(0)
    end

    it 'works with a custom :class_name' do
      delivery_service = DeliveryService.create!
      pizza = delivery_service.pizzas.create!
      toppings = [pizza.toppings.create!,
                  pizza.toppings.create!]

      delivery_service.destroy!

      expect(DeliveryService.where(id: delivery_service.id).count).to eq(0)
      expect(Pizza.where(id: pizza.id).count).to eq(0)
      expect(Ingredient.where(id: toppings.map(&:id)).count).to eq(0)
    end

    it 'works on records with a custom :primary_key' do
      project = Project.create!(my_primary_key: 'project_1')
      tasks = [project.tasks.create!(my_primary_key: 'task_1'),
               project.tasks.create!(my_primary_key: 'task_2')]

      other_project = Project.create!(my_primary_key: 'project_2')
      other_tasks = [other_project.tasks.create!(my_primary_key: 'task_3'),
                     other_project.tasks.create!(my_primary_key: 'task_4')]

      project.destroy!

      expect(Project.where(my_primary_key: project.my_primary_key).count).to eq(0)
      expect(Task.where(my_primary_key: tasks.map(&:my_primary_key)).count).to eq(0)

      expect(Project.where(my_primary_key: other_project.my_primary_key).count).to eq(1)
      expect(Task.where(my_primary_key: other_tasks.map(&:my_primary_key)).count).to eq(2)
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

    it 'deletes sub-associations with dependent: :delete, but none below those' do
      house = House.create!
      renters = [house.renters.create!,
                 house.renters.create!]
      letterboxes = [renters.first.letterboxes.create!,
                     renters.first.letterboxes.create!,
                     renters.last.letterboxes.create!,
                     renters.last.letterboxes.create!]
      letters = [letterboxes.first.letters.create!,
                 letterboxes.first.letters.create!,
                 letterboxes.last.letters.create!]

      DeleteRecursively.all(House)

      expect(House.where(id: house.id).count).to eq(0)
      expect(Renter.where(id: renters.map(&:id)).count).to eq(0)
      expect(Letterbox.where(id: letterboxes.map(&:id)).count).to eq(0)
      expect(Letter.where(id: letters.map(&:id)).count).to eq(3)
    end

    it 'takes a criteria argument' do
      2.times { Blog.create! && Post.create! && Comment.create! }
      Blog.first.update_attribute(:id, 0)
      Post.first.update_attribute(:id, 0)
      Comment.first.update_attribute(:id, 0)

      DeleteRecursively.all(Blog, id: 0)

      expect(Blog.count).to eq(1)
      expect(Post.count).to eq(1)
      expect(Comment.count).to eq(1)

      # clean up
      DeleteRecursively.all(Blog)
    end

    it 'applies criteria only to models that have corresponding columns' do
      2.times { Blog.create! && Post.create! && Comment.create! }

      DeleteRecursively.all(Blog, inexistent_column: 'some_value')

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
