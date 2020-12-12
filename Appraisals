%w[
  5.1.7
  5.2.4.4
  6.1.0
].each do |version|
  appraise "activerecord-#{version}" do
    gem 'activerecord', version

    group :development do
      gem 'rails', version
    end
  end
end
