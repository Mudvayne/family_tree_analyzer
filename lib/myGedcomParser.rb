require './lib/gedcom'
require './lib/individual'
require './lib/family'

#todo: occu
#shortcut: %w(foo bar) = ["foo", "bar"]

class MyGedcomParser < GEDCOM::Parser
  def initialize
    super

    #individuals
    @persons = Array.new
    @id_person = nil
    @gender = nil
    @name = nil
    @occupation = nil
    @date_birth = nil
    @date_marriage = nil
    @date_death = nil
    @date_burial = nil
    @location_birth = nil
    @location_marriage = nil
    @location_death = nil
    @location_burial = nil
    @child_in_family = nil
    @parent_in_families = nil

    before %w(INDI) do |data|
      @parent_in_families = Array.new
      @id_person = data
    end

    before %w(INDI SEX) do |data|
      @gender = data
    end

    before %w(INDI NAME) do |data|
      @name = data
    end

    before %w(INDI BIRT DATE) do |data|
      @date_birth = data
    end

    before %w(INDI BIRT PLAC) do |data|
      @location_birth = data
    end

    before %w(INDI DEAT DATE) do |data|
      @date_death = data
    end

    before %w(INDI DEAT PLAC) do |data|
      @location_death = data
    end

    before %w(INDI BURI DATE) do |data|
      @date_death = data
    end

    before %w(INDI BURI PLAC) do |data|
      @location_burial = data
    end 

    before %w(INDI FAMS) do |data|
      @parent_in_families.push(data) 
    end

    before %w(INDI FAMC) do |data|
      @child_in_family = data
    end

    after %w(INDI) do
      @persons.push(Individual.new(@id_person, @gender, @name, @occupation, @date_birth, @date_death, @date_burial, @location_birth, @location_death, @location_burial, @parent_in_families, @child_in_family))
      empty_fields
    end

    #families
    @families = Array.new
    @id_family = nil
    @husband = nil
    @wife = nil
    @children = nil
    @date_married = nil

    before %w(FAM) do |data|
      @children = Array.new
      @id_family = data
    end

    before %w(FAM HUSB) do |data|
      @husband = data
    end

    before %w(FAM WIFE) do |data|
      @wife = data
    end

    before %w(FAM CHIL) do |data|
      @children.push(data)
    end

    before %w(FAM MARR DATE) do |data|
      @date_married = data
    end

    after %w(FAM) do
      @families.push(Family.new(@id_family, @husband, @wife, @children, @date_married))
      empty_fields
    end
  end

  def get_all_persons
    @persons
  end

  def get_all_families
    @families
  end

  private
  def empty_fields
    @id_person = nil
    @name = nil
    @occupation = nil
    @date_birth = nil
    @date_marriage = nil
    @date_death = nil
    @date_burial = nil
    @location_birth = nil
    @location_marriage = nil
    @location_death = nil
    @location_burial = nil
    @child_in_family = nil
    @parent_in_families = nil
    @id_family = nil
    @husband = nil
    @wife = nil
    @children = nil
    @date_married = nil
    @location_married = nil
  end
end