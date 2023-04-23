# after changes, run `bundle exec appraisal install`
%w[
  5.2.6
  6.1.4.1
  7.0.1
].each do |version|
  appraise "activerecord-#{version}" do
    gem 'activerecord', version

    group :development, :test do
      gem 'rails', version
      remove_gem 'appraisal'
    end
  end
end
