require './lib/myGedcomParser'
require './lib/individual'
require './lib/family'

class Test

  def initialize
    parser = MyGedcomParser.new
    parser.parse './royal.ged'
    @all_persons = parser.get_all_persons
    @all_persons_hashmap = Hash.new
    @all_persons.each do |person|
      @all_persons_hashmap[person.id] = person
    end
    @families = parser.get_all_families

    #blubbor
    @persons = @all_persons
  end

  def find_all_descendants person_id, decendent_ids
    @families.each do |family|
      if family.husband == person_id || family.wife == person_id
        decendent_ids = decendent_ids.push(family.children)
        family.children.each do |child|
          find_all_descendants child, decendent_ids
        end
      end
    end
    return decendent_ids
  end

  #returns found person_id or nil if no person was found
  def find_person_by_kekule person_id, kekule
    
    #generate path
    calc = kekule
    path = Array.new

    while calc > 1 do 
      if calc % 2 == 0 
        path.push(0) #male
      else 
        path.push(1) #female
      end
      calc /= 2
    end
    path.reverse! #reverse the path for cycle later

    actual_person_id = person_id
    family_id = ""
    
    #go through path
    while path.count > 0 do
      person = get_person_by_id actual_person_id
      family_id = person.child_in_family
      if family_id == "N/A" then return nil end #person with empty FAMC field found in path -> return nil
      family = get_family_by_id family_id

      if path.shift == 0 # go for father
        actual_person_id = family.husband
      else # go for mother
        actual_person_id = family.wife
      end
    end

    return actual_person_id
  end

  def get_person_by_id person_id
    @all_persons.each do |person|
      if person.id == person_id
        return person
      end
    end
    return "no such person"
  end

  def get_family_by_id family_id
    @families.each do |family|
      if family.id == family_id
        return family
      end
    end
    return "no such family"
  end

  def get_males
    males = Array.new
    @persons.each do |i|
      if i.gender == "M"
        males.push(i)
      end
    end
    return males
  end

  def get_females
    femails = Array.new
    @persons.each do |i|
      if i.gender == "F"
        femails.push(i)
      end
    end
    return femails
  end
end
