class Individual

  attr_reader :id, :gender, :occupation, :date_birth, :date_death, :date_burial, :location_birth, :location_death, :location_burial, :parent_in_families, :child_in_family

  def initialize(id, gender, name, occupation, date_birth, date_death, date_burial, location_birth, location_death, location_burial, parent_in_families, child_in_family)
    @id = id || "N/A"
    @gender = gender || "N/A"
    @name = name.gsub("_"," ") || "N/A"
    @occupation = occupation || "N/A"
    @date_birth = date_birth || "N/A"
    @date_death = date_death || "N/A"
    @date_burial = date_burial || "N/A"
    @location_birth = location_birth || "N/A"
    @location_death = location_death || "N/A"
    @location_burial = location_burial || "N/A"
    @child_in_family = child_in_family || "N/A"
    @parent_in_families = parent_in_families
  end

  def firstname
    if @name == "//" || @name == "/"
      return "N/A"
    end
    if @name.split("/").first != nil && @name.split("/").first != ""
      return @name.split("/").first.strip
    end
    return "N/A"
  end

  def lastname
    if @name == "//" || @name == "/"
      return "N/A"
    end
    if firstname == "N/A"
      return @name.delete("/")
    else
      if @name.split("/").last.size != @name.delete("/").size
        return @name.split("/").last.strip
      else
        return "N/A"
      end
    end
  end

  def to_s
    string = 
    "Firstname: " + firstname + "; Lastname: " +lastname + "; Occupation: " + occupation + 
    "; Born in: " + location_birth + ", Date: " + date_birth + 
    "; Died in: " + location_death + ", Date: " + date_death + 
    "; Buried in: " + location_burial + ", Date: " + date_burial + 
    "; Child in: " + child_in_family + "; Parent in: "
    
    parent_in = ""

    if not @parent_in_families.empty?
      @parent_in_families.each do |family|
         parent_in += family + " "
      end
    else
      parent_in = "N/A"
    end

    string += parent_in

    return string
  end

  def nationality
    return @location_birth.split(",").last
  end
end