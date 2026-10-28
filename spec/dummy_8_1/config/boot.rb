# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../gemfiles/rails_8_1.gemfile', __dir__)

require 'bundler/setup'
$LOAD_PATH.unshift File.expand_path('../../../lib', __dir__)
