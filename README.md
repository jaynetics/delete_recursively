
# DeleteRecursively

[![Gem Version](https://badge.fury.io/rb/delete_recursively.svg)](http://badge.fury.io/rb/delete_recursively)
[![Build Status](https://travis-ci.org/jaynetics/delete_recursively.svg?branch=master)](https://travis-ci.org/jaynetics/delete_recursively)
[![codecov](https://codecov.io/gh/jaynetics/delete_recursively/branch/master/graph/badge.svg)](https://codecov.io/gh/jaynetics/delete_recursively)
[![Code Climate](https://codeclimate.com/github/jaynetics/delete_recursively/badges/gpa.svg)](https://codeclimate.com/github/jaynetics/delete_recursively)

This gem adds a new option for ActiveRecord associations:

`dependent: :delete_recursively`

When you destroy a record, all records that are associated using this option will be deleted recursively, without instantiating any of them. See below for a more detailed explanation of why this is cool.

Note that, just like `dependent: :delete` or `dependent: :delete_all`, this new option does **not** trigger the `around/before/after_destroy` callbacks of the dependent records.

However, it is possible to have `dependent: :destroy` associations anywhere within a chain of models that are otherwise associated with `dependent: :delete_recursively`. The `:destroy` option will work normally anywhere up or down the line, instantiating and destroying all relevant records and thus also triggering their callbacks.

## Installation

Add, install, or require `delete_recursively`.

## Usage

Assume we have these classes:

```ruby
class Blog < ApplicationRecord
  has_many :posts, dependent: :delete_recursively
end

class Post < ApplicationRecord
  belongs_to :blog
  has_many :comments, dependent: :delete
end

class Comment < ApplicationRecord
  belongs_to :post
end
```

This will delete `my_blog`, all of it's posts, and all comments belonging to any of these posts:
```ruby
my_blog.destroy
```

Note that using `dependent: :delete` ends the recursion. If the Comment model above had any associations, those would not be touched.

There is also the utility command `::all` for mass operations. This will delete **all** Blogs, Posts, and Comments (even orphans):
```ruby
DeleteRecursively.all(Blog)
```

`::all` accepts a criteria Hash to limit the action's scope, much like `ActiveRecord::delete_all`. For any model in the chain that has the corresponding columns, these criteria will limit which records are deleted. For instance, assuming that all our models have timestamps and a user_id, this will delete all Blogs, Posts, and Comments created by *evil_user* in the last two days:

```ruby
DeleteRecursively.all(Blog, created_at: 2.days.ago..Time.now, user_id: evil_user.id)
```

## Explanation

Generally speaking, this gem addresses the dilemma that on the one hand a chain of associations with the `dependent: :destroy` option works recursively, but is very inefficient, whereas on the other hand a chain of associations with the `dependent: :delete_all` option is efficient, but works only to a depth of one level.

`:delete_recursively` works to any depth *and* is efficient.

Let's assume you have a Blog model. There is one Blog record that you want to destroy. This Blog record has 100 Post records. Each of these Post records has about 10 Comment records.

Now let's assume these models are chained together with `dependent: :destroy`.

In that case, destroying the Blog record will instantiate all Posts and Comments and various related objects, and destroy all of these records individually. That means instantiating 10.000s of objects and performing countless SQL calls.

With `dependent: :delete_recursively`, that will take just a tiny, fixed number of objects and a tiny, fixed number of SQL calls. The number of records no longer matters, because associated records are found by evaluating associations defined on the model class and finding and deleting dependent records in batches.

## Credits

DeleteRecursively was heavily inspired by JD Isaacks' gem [recurse-delete](https://github.com/jisaacks/recurse-delete). recurse-delete works a litte differently, though. It adds a new method to ActiveRecord instances. This method can then be called manually on a record, and it will efficiently delete the record and all of it's dependencies that have the `:delete`, `:delete_all` or `:destroy` option.
