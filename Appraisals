# after changes, run `bundle exec appraisal install`
%w[
  7.1
  7.2
  8.0
].each do |version|
  constraint = [">= #{version}", "< #{version.sub(/\d+\z/, &:succ)}"]
  appraise "activerecord-#{version}" do
    gem 'activerecord', constraint

    group :development, :test do
      gem 'rails', constraint
      remove_gem 'appraisal'
    end
  end
end
