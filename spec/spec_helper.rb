require 'rubygems'
require 'fastpay'
require 'rspec/its'
require 'webmock/rspec'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixture/vcr'
  c.hook_into :webmock
end


