# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{activerecord_base_without_table}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonathan Viney", "Peter Abrahamsen", "Peter Suschlik"]
  s.date = %q{2009-03-13}
  s.description = %q{Get the power of ActiveRecord models, including validation, without having a table in the database.}
  s.email = %q{peter-arwbt@suschlik.de}
  s.files = [
    "CHANGELOG", "README.rdoc", "Rakefile",
    "lib/active_record/base_without_table.rb", "lib/activerecord_base_without_table.rb",
    "test/abstract_unit.rb", "test/active_record_base_without_table_test.rb", "test/database.yml"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/splattael/activerecord_base_without_table}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.summary = %q{Get the power of ActiveRecord models, including validation, without having a table in the database.}
end
