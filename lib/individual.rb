class Individual

  attr_reader :id, :occupation, :date_birth, :date_marriage, :date_death, :date_burial, :location_birth, :location_marriage, :location_death, :location_burial

  def initialize(id, name, occupation, date_birth, date_marriage, date_death, date_burial, location_birth, location_marriage, location_death, location_burial)
    @id = id || "N/A"
    @name = name || "N/A"
    @occupation = occupation || "N/A"
    @date_birth = date_birth || "N/A"
    @date_marriage = date_marriage || "N/A"
    @date_death = date_death || "N/A"
    @date_burial = date_burial || "N/A"
    @location_birth = location_birth || "N/A"
    @location_marriage = location_marriage || "N/A"
    @location_death = location_death || "N/A"
    @location_burial = location_burial || "N/A"
    to_s
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
    "firstname: " + firstname + "; lastname: " +lastname + "; occupation: " + occupation + 
    "; born in: " + location_birth + ", date: " + date_birth + ", married in: " + 
    location_marriage + ", date: " + date_marriage + "; died in: " + location_death + 
    ", date: " + date_death + "; buried in: " + location_burial + ", date: " + date_burial
  end
end