%w[
  4.2.11.1
  5.0.7.2
  5.1.6.2
  5.2.2.1
  6.0.0.beta3
].each do |version|
  appraise "activerecord-#{version}" do
    gem 'activerecord', version

    group :development do
      gem 'rails', version
    end
  end
end
