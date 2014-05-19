require './lib/gedcom'

class Person
  attr_accessor :name
  def initialize( name = nil)
    @name = name
  end
end

class MyGedcomParser < GEDCOM::Parser
  def initialize
    super
    @currentPerson = Person.new
    before %w(INDI NAME) do |data|
      @currentPerson.name = data if @currentPerson.name == nil
      puts @currentPerson.name
    end
  end
end