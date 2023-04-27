# Changelog

## Unreleased

## v1.2.2
### Fixed
- fixed unnecessary void DELETE calls for empty relations
  - thanks to [Richard Nienaber](https://github.com/rjnienaber) for the report

## v1.2.1
### Fixed
- NoMethodError when using v1.2.0 without rails. D'oh.

## v1.2.0
### Added
- support for the inverse of polymorphic associations
- warning for unresolvable associations

### Fixed
- error if any polymorphic association in the app has `inverse_of` defined
  - thanks to [Richard Nienaber](https://github.com/rjnienaber) for the report
- incomplete deletion of associations that are reached multiple times
  - i.e. via multiple routes in the sub-association tree of the given record

## v1.1.0
### Added
- support for polymorphic associations
- `ActiveRecord::Base#delete_recursively`
  - an optional `force: true` argument enforces the usage of `#delete` even for `destroy` associations
- `ActiveRecord::Relation#delete_all_recursively`
  - an optional `force: true` argument enforces the usage of `#delete` even for `destroy` associations

### Fixed
- fixed an infinite loop for bi-directional `dependent: :delete(_recursively)` callbacks
- fixed handling of `belongs_to` associations with a name that doesn't match the class name and no custom foreign key

## v1.0.2
### Fixed
- relaxed dependency spec to include rails 7

## v1.0.1
### Fixed
- fixed LoadError when requiring the gem by adding `version.rb` to the gem files

## v1.0.0
### Changed
- records of subassociations with the `:delete` or `:delete_all` option are now deleted during recursive deletion; associations that follow these in the association tree are still ignored

### Added
- added support for `has_many :through` associations
