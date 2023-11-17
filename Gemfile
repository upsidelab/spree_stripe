source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'spree', github: 'spree/spree', branch: 'main'
gem 'spree_backend', github: 'spree/spree', branch: 'main'
gem 'rails-controller-testing'

if ENV['DB'] == 'mysql'
  gem 'mysql2'
else
  gem 'pg', '~> 1.1'
end

gemspec
