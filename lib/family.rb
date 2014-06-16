class Family

  attr_reader :id, :husband, :wife, :children, :date_married

  def initialize id, husband, wife, children, date_married
    @id = id || "N/A"
    @husband = husband || "N/A"
    @wife = wife || "N/A"
    @children = children || "N/A"
    @date_married = date_married || "N/A"
  end

  def to_s
    string = "Family: " + id + " Husband: " + husband + " Wife: " + wife + " Date Marriage: " + date_married + " Children: "
    string_children = ""
    if not children.empty?
      children.each do |child|
        string_children += child + " "
      end
    end
    string += string_children
    return string
  end
end