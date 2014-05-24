b = nil
if b.split("/").last != nil && b.split("/").last.size != b.delete("/").size
  puts b.split("/").last
else
  if b[0] == "/" #no firstname
    puts b.split("/").last
  else
    puts "no lastname"
  end
end