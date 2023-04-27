require 'spec_helper'

describe DeleteRecursively do
  let(:blog_with_posts_and_comments) do
    blog = Blog.create!
    posts = [blog.posts.create!,
            blog.posts.create!]
    comments = [posts[0].comments.create!,
                posts[1].comments.create!]
    blog
  end

  describe 'dependent: :delete_recursively' do
    it 'deletes all dependent records when a record is destroyed' do
      blog = blog_with_posts_and_comments
      expect { blog.destroy! }
        .to change { Blog.count }.to(0)
        .and change { Post.count }.to(0)
        .and change { Comment.count }.to(0)
    end

    it 'uses #destroy to delete records associated as dependent: :destroy' do
      blog = blog_with_posts_and_comments

      expect(Rails.logger)
        .to receive(:info)
        .with('Comment destroy callback!')
        .exactly(2).times

      blog.destroy!
    end

    it 'does not trigger DB calls for empty relations' do
      expect(Post).to receive(:delete)
      expect(Comment).to receive(:destroy)
      blog_with_posts_and_comments.destroy!

      expect(Post).not_to receive(:delete)
      expect(Comment).not_to receive(:destroy)
      Blog.create!.destroy!
    end

    it 'works on has_one: associations' do
      delivery_service = DeliveryService.create!
      pizza = delivery_service.pizzas.new
      pizza.box = Box.create!
      pizza.save!

      expect { delivery_service.destroy! }
        .to change { DeliveryService.count }.to(0)
        .and change { Pizza.count }.to(0)
        .and change { Box.count }.to(0)
    end

    it 'works on has_many: :through associations' do
      house = House.create!
      renters = [house.renters.create!,
                 house.renters.create!]
      letterboxes = [renters.first.letterboxes.create!,
                     renters.first.letterboxes.create!,
                     renters.last.letterboxes.create!,
                     renters.last.letterboxes.create!]

      expect { house.destroy! }
        .to change { House.count }.to(0)
        .and change { Renter.count }.to(0)
        .and change { Letterbox.count }.to(0)
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

      expect { house.destroy! }
        .to change { House.count }.to(0)
        .and change { Renter.count }.to(0)
        .and change { Letterbox.count }.to(0)
        .and change { Letter.count }.by(0) # note the `by`
    end

    it 'does not delete records without a dependent option' do
      delivery_service = DeliveryService.create!
      pizza = delivery_service.pizzas.new
      pizza.programmer = Programmer.create!
      pizza.save!

      flavor = pizza.flavors.create!

      expect { delivery_service.destroy! }
        .to change { Flavor.count }.by(0)
    end

    # belongs_to is the only association type that needs a unique handling if it
    # is present on the first destroyed record (the callee or "point of entry"),
    # and thus the only type that needs two different tests.

    it 'works on belongs_to: associations of the callee' do
      pizza = Pizza.new
      pizza.programmer = Programmer.create!
      pizza.save!

      expect { pizza.destroy! }
        .to change { Pizza.count }.to(0)
        .and change { Programmer.count }.to(0)
    end

    it 'works on belongs_to: associations further down the chain' do
      delivery_service = DeliveryService.create!
      pizza = delivery_service.pizzas.new
      pizza.programmer = Programmer.create!
      pizza.save!

      expect { delivery_service.destroy! }
        .to change { DeliveryService.count }.to(0)
        .and change { Pizza.count }.to(0)
        .and change { Programmer.count }.to(0)
    end

    it 'works with a custom :class_name' do
      delivery_service = DeliveryService.create!
      pizza = delivery_service.pizzas.create!
      toppings = [pizza.toppings.create!,
                  pizza.toppings.create!]

      expect { delivery_service.destroy! }
        .to change { DeliveryService.count }.to(0)
        .and change { Pizza.count }.to(0)
        .and change { Ingredient.count }.to(0)
    end

    it 'works with association with implicit foreign keys that differ from the model name' do
      baker = Pizza::Baker.create!
      pizza = Pizza.create!(baker: baker)

      expect { pizza.destroy! }
        .to change { Pizza::Baker.count }.to(0)
        .and change { Pizza.count }.to(0)
    end

    it 'works on records with a custom :primary_key' do
      project = Project.create!(my_primary_key: 'project_1')
      tasks = [project.tasks.create!(my_primary_key: 'task_1'),
               project.tasks.create!(my_primary_key: 'task_2')]

      other_project = Project.create!(my_primary_key: 'project_2')
      other_tasks = [other_project.tasks.create!(my_primary_key: 'task_3'),
                     other_project.tasks.create!(my_primary_key: 'task_4')]

      expect { project.destroy! }
        .to change { Project.ids }.to([other_project.id])
        .and change { Task.ids }.to(other_tasks.map(&:id))
    end

    it 'works on polymorphic associations' do
      price = Price.create!
      pizza = Pizza.create!(price: price)
      pizza.save!
      pizza.toppings.create!

      expect { price.destroy! }
        .to change { Price.count }.to(0)
        .and change { Pizza.count }.to(0)
        .and change { Ingredient.count }.to(0)
    end

    it 'works on the inverse of polymorphic associations' do
      # this is also a test of infinite loop avoidance, because
      # dependent: :delete_recursively is defined both ways in this case.
      price = Price.create!
      doomsday_device = DoomsdayDevice.create!(price: price)

      other_price = Price.create!
      other_doomsday_device = DoomsdayDevice.create!(price: other_price)

      expect { doomsday_device.destroy! }
        .to change { DoomsdayDevice.pluck(:id) }.to([other_doomsday_device.id])
        .and change { Price.pluck(:id) }.to([other_price.id])
    end

    it 'works on the inverse of polymorphic associations with inverse_of' do
      programmer = Programmer.create!
      pizza = Pizza.create!(beneficiary: programmer)

      other_programmer = Programmer.create!
      other_pizza = Pizza.create!(beneficiary: other_programmer)

      expect { programmer.destroy! }
        .to change { Programmer.pluck(:id) }.to([other_programmer.id])
        .and change { Pizza.pluck(:id) }.to([other_pizza.id])
    end

    it 'works on associations reached via multiple routes in the association tree' do
      programmer1 = Programmer.create!
      programmer2 = Programmer.create!(colleague: programmer1)
      # require 'debug';debugger
      pizza1 = Pizza.create!(beneficiary: programmer1)
      pizza2 = Pizza.create!(beneficiary: programmer2)

      other_programmer = Programmer.create!
      other_pizza = Pizza.create!(beneficiary: other_programmer)

      expect { programmer2.destroy! }
        .to change { Programmer.pluck(:id) }.to([other_programmer.id])
        .and change { Pizza.pluck(:id) }.to([other_pizza.id])
    end
  end

  describe '::all' do
    it 'deletes all class records and all records of dependent classes' do
      2.times { Blog.create! && Post.create! && Comment.create! }

      expect { DeleteRecursively.all(Blog) }
        .to change { Blog.count }.to(0)
        .and change { Post.count }.to(0)
        .and change { Comment.count }.to(0)
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

      expect { DeleteRecursively.all(House) }
        .to change  { House.count }.to(0)
        .and change { Renter.count }.to(0)
        .and change { Letterbox.count }.to(0)
        .and change { Letter.count }.by(0) # note the `by`
    end

    it 'takes a criteria argument' do
      2.times { Blog.create! && Post.create! && Comment.create! }
      Blog.first.update_attribute(:id, 0)
      Post.first.update_attribute(:id, 0)
      Comment.first.update_attribute(:id, 0)

      expect { DeleteRecursively.all(Blog, id: 0) }
        .to change { Blog.ids }.to([Blog.last.id])
        .and change { Post.ids }.to([Post.last.id])
        .and change { Comment.ids }.to([Comment.last.id])
    end

    it 'applies criteria only to models that have corresponding columns' do
      2.times { Blog.create! && Post.create! && Comment.create! }

      expect { DeleteRecursively.all(Blog, inexistent_column: 'some_value') }
        .to change { Blog.count }.to(0)
        .and change { Post.count }.to(0)
        .and change { Comment.count }.to(0)
    end

    it 'works with a custom :class_name' do
      2.times { DeliveryService.create! && Pizza.create! && Ingredient.create! }

      expect { DeleteRecursively.all(DeliveryService) }
        .to change { DeliveryService.count }.to(0)
        .and change { Pizza.count }.to(0)
        .and change { Ingredient.count }.to(0)
    end

    it 'works on records with a custom :primary_key' do
      2.times { Project.create! && Task.create! }

      expect { DeleteRecursively.all(Project) }
        .to change { Project.count }.to(0)
        .and change { Task.count }.to(0)
    end
  end

  describe 'ActiveRecord::Base#delete_recursively' do
    it 'deletes the record and its dependent records' do
      blog = blog_with_posts_and_comments

      # This should not trigger destroy callbacks on the record itself,
      # but should do so on associations using dependent: :destroy.
      expect(Rails.logger).not_to receive(:debug).with('Blog destroy callback!')
      expect(Rails.logger).to receive(:info)
        .with('Comment destroy callback!')
        .exactly(2).times

      expect { blog.delete_recursively }
        .to change { Blog.count }.to(0)
        .and change { Post.count }.to(0)
        .and change { Comment.count }.to(0)
    end
  end

  describe 'ActiveRecord::Relation#delete_all_recursively' do
    it 'deletes the records and their dependent records' do
      blog = blog_with_posts_and_comments
      relation = Post.limit(1)
      expect { relation.delete_all_recursively }
        .to change { Post.count }.from(2).to(1)
        .and change { Comment.count }.from(2).to(1)
    end
  end

  describe 'DeleteRecursively::AssociatedClassFinder.warn_empty_result' do
    it 'works' do
      ref = Blog.reflect_on_all_associations.find { |r| r.name == :posts } || fail
      expect do
        DeleteRecursively::AssociatedClassFinder.send(:warn_empty_result, ref)
      end.to output(/Blog#posts/).to_stderr
    end
  end
end
