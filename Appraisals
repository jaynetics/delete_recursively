%w[
  5.2.6
  6.1.4.1
  7.0.0.alpha2
].each do |version|
  appraise "activerecord-#{version}" do
    gem 'activerecord', version

    group :development do
      gem 'rails', version
    end
  end
end
