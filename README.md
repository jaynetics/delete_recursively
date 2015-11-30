
# DeleteRecursively

[![Gem Version](https://badge.fury.io/rb/delete_recursively.svg)](http://badge.fury.io/rb/delete_recursively)
[![Build Status](https://travis-ci.org/janosch-x/delete_recursively.svg?branch=master)](https://travis-ci.org/janosch-x/delete_recursively)
[![Dependency Status](https://gemnasium.com/janosch-x/delete_recursively.svg)](https://gemnasium.com/janosch-x/delete_recursively)
[![Code Climate](https://codeclimate.com/github/janosch-x/delete_recursively/badges/gpa.svg)](https://codeclimate.com/github/janosch-x/delete_recursively)
[![Test Coverage](https://codeclimate.com/github/janosch-x/delete_recursively/badges/coverage.svg)](https://codeclimate.com/github/janosch-x/delete_recursively/coverage)

This gem was inspired by JD Isaacks' gem [recurse-delete](https://github.com/jisaacks/recurse-delete). Unlike recurse-delete, it does not rely on manually triggering recursive deletion, but instead adds a new option for ActiveRecord associations:

*dependent: :delete_recursively*

Much like recurse-delete, this allows dependent records to be deleted recursively, without instantiating any of them.

This addresses the dilemma that on the one hand a chain of associations with the *dependent: :destroy* option works recursively, but is very inefficient, whereas on the other hand a chain of associations with the *dependent: :delete_all* option is efficient, but works only to a depth of one level.

Note that, just like *dependent: :delete* or *dependent: :delete_all*, this new option will *not* trigger the around/before/after_destroy callbacks of dependent records.

## Installation

Add, install, or require *delete_recursively*.

## Usage

Assume we have these classes:

```ruby
class Blog < ActiveRecord::Base
  has_many :posts, dependent: :delete_recursively
end

class Post < ActiveRecord::Base
  belongs_to :blog
  has_many :comments, dependent: :delete_recursively
end

class Comment < ActiveRecord::Base
  belongs_to :post
end
```

This will delete my_blog and all it's posts and comments:
```ruby
my_blog.destroy
```

This will delete all Blogs, Posts, and Comments (even orphans):
```ruby
DeleteRecursively.all(Blog)
```
