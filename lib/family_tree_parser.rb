require './lib/gedcom'
require './lib/individual'

class MyGedcomParser < GEDCOM::Parser
  #attr_accessor :persons
  def initialize
    super
    @persons = Array.new

    @id = nil
    @name = nil
    @dateofbirth = nil
    @dateofmarriage = nil
    @dateofdeath = nil
    @dateofburial = nil
    @placeofbirth = nil
    @placeofmarriage = nil
    @placeofdeath = nil
    @placeofburial = nil

    before %w(INDI) do |data|
      @id = data
    end

    before %w(INDI NAME) do |data|
      @name = data
    end

    before %w(INDI BIRT DATE) do |data|
      @dateofbirth = data
    end

    before %w(INDI BIRT PLAC) do |data|
      @placeofburial = data
    end

    before %w(INDI DEAT DATE) do |data|
      @dateofdeath = data
    end

    before %w(INDI DEAT PLAC) do |data|
      @placeofdeath = data
    end

    before %w(INDI BURI DATE) do |data|
      @dateofdeath = data
    end

    before %w(INDI BURI PLAC) do |data|
      @placeofburial = data
    end 

    after %w(INDI) do
      @persons.push(Individual.new(@id, @name, @dateofbirth, @dateofmarriage, @dateofdeath, @dateofburial, @placeofbirth, @placeofmarriage, @placeofdeath, @placeofburial))
    end

    #puts @name

    #@persons.push(Individual.new(@id, @name, @dateofbirth, @dateofmarriage, @dateofdeath, @dateofburial, @placeofbirth, @placeofmarriage, @placeofdeath, @placeofburial))

  end

  def get_all_persons
    @persons
  end
end