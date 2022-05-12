# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip 
# tell HEROKU what ruby version we use

# Web API
gem 'json'
gem 'puma', '~>5.6'  #'~>5'
gem 'roda', '~>3.54' #'~>3'

# Configuration
gem 'figaro', '~>1'
gem 'rake', '~>13'

# Parse HTML and XML in Ruby
# gem 'nokogiri', '~> 1.6', '>= 1.6.8'

# Security
gem 'bundler-audit'
gem 'rbnacl', '~>7'

# Database
gem 'hirb', '~>0'
gem 'sequel', '~>5'

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
end

# Debugging
gem 'pry' # necessary for rake console

# Development
group :development do
  gem 'pry'
  gem 'rerun'
  gem 'rubocop'
  gem 'rubocop-performance'
end

group :development, :test do
  gem 'rack-test'
  gem 'sequel-seed'
  gem 'sqlite3','~>1.3.13' # Lower the edition for my wins env
endgit

# Mistake Avoiding 
gem 'parser', '~> 3.1'

# Quality
gem 'rubocop'