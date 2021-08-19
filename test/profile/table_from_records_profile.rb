#!/usr/bin/env ruby

project_root = File.expand_path('../..', __dir__)

ENV['BUNDLE_GEMFILE'] ||= File.join(project_root, 'Gemfile')
require 'bundler/setup'
require 'ruby-prof'
require 'time'
require 'berkeley_library/tind/marc/xml_reader'
require 'berkeley_library/tind/export/table'

def timestamp
  Time.now.iso8601
end

def html_report_path
  "/tmp/profile-#{timestamp}.html"
end

def records
  @records ||= begin
    input_file_path = File.join(project_root, 'spec/data/records-api-search-p1.xml')
    BerkeleyLibrary::TIND::MARC::XMLReader.new(input_file_path, freeze: true).to_a
  end
end

def do_profile
  RubyProf.start
  BerkeleyLibrary::TIND::Export::Table.from_records(records)
  RubyProf.stop
end

def print_text_report(result)
  RubyProf::FlatPrinter.new(result).print($stdout)
end

def show_html_report(result)
  File.open(html_report_path, 'w') do |f|
    RubyProf::GraphHtmlPrinter.new(result).print(f)
    `open #{f.path}`
  end
end

result = do_profile
print_text_report(result)
show_html_report(result)
