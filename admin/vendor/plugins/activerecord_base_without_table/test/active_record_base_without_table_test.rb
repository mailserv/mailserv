require File.dirname(__FILE__) + '/abstract_unit'

class Person < ActiveRecord::BaseWithoutTable
  column :name, :string
  column :lucky_number, :integer, 4
  
  validates_presence_of :name
end

class Employee < Person
  column :salary, :integer
end

class House < ActiveRecord::BaseWithoutTable
  column    :person, :string
  serialize :person
end

class ActiveRecordBaseWithoutTableTest < Test::Unit::TestCase

  def test_default_value
    assert_equal 4, Person.new.lucky_number
  end
  
  def test_validation
    p = Person.new
    
    assert !p.save
    assert p.errors[:name]
    
    assert p.update_attributes(:name => 'Name')
  end
  
  def test_typecast
    assert_equal 1, Person.new(:lucky_number => "1").lucky_number
  end
  
  def test_cached_column_variables_reset_when_column_defined
    cached_variables = %w(column_names columns_hash content_columns dynamic_methods_hash generated_methods)
    
    Person.column_names
    Person.columns_hash
    Person.content_columns
    Person.column_methods_hash
    Person.generated_methods
    
    cached_variables.each { |v| assert_not_nil Person.instance_variable_get("@#{v}") }
    Person.column :new_column, :string
    cached_variables.each { |v| assert_nil Person.instance_variable_get("@#{v}") }
  end

  def test_serialization
    h = House.new(:person => Person.new)

    assert_instance_of Person, h.person
    quoted = h.connection.quote h.person, h.column_for_attribute('person')
    assert_kind_of String, quoted
    assert_match /---/, quoted
  end

  def test_inheritance
    e = Employee.new(:salary => 5000, :name => "Enoch Root")

    assert_equal "Enoch Root", e.name
    assert_equal 5000, e.salary
  end

end
