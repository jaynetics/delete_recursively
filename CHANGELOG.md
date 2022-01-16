# Changelog

## Unreleased
### Added
- support for polymorphic associations
- `ActiveRecord::Base#delete_recursively`
- `ActiveRecord::Relation#delete_all_recursively`

### Fixed
- fixed an infinite loop for bi-directional `dependent: :delete(_recursively)` callbacks

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
