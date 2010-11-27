CURRENT_DIR = File.dirname(__FILE__)

# stdlib
require "rexml/document"

# external dependencies
begin
  require "bundler/setup"
rescue LoadError
  require "rubygems"
  require "bundler/setup"
end

Bundler.require :default

# internal dependencies
require 'typedset'
require 'confetti/version'
require 'confetti/helpers'

require 'confetti/template'
require 'confetti/templates/base'
require 'confetti/templates/java_checks'
Dir[File.join(CURRENT_DIR, 'confetti', 'templates', '*')].each do |file|
  require file if File.extname(file) == ".rb"
end
require 'confetti/template_helper'

require 'confetti/config'
require 'confetti/config/feature'
