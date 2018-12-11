require 'simplecov'
SimpleCov.start do
    add_filter 'spec/'
end

if(ENV['CI'])
    require 'codecov'
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/ionic' # import the actual plugin

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)
