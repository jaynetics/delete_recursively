%w[
  5.1.7
  5.2.4.1
  6.0.2.1
].each do |version|
  appraise "activerecord-#{version}" do
    gem 'activerecord', version

    group :development do
      gem 'rails', version
    end
  end
end
