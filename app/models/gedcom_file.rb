require 'zip'

class GedcomFile < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :filename

  def self.create_zip_archive
    users = User.all.select { |user| user.gedcom_files.size > 0 }
    
    io = StringIO.new
    Zip::OutputStream.write_buffer(io) do |output_stream|
      users.each do |user|
        user.gedcom_files.each do |gedcom_file|
          path = user.escape_mail_for_filesystem + "/" + gedcom_file.filename + ".ged"
          output_stream.put_next_entry(path)
          output_stream.puts(gedcom_file.data)
        end
      end
    end
    io.rewind
    return io.string
  end

  def filename_with_extension
    return filename + ".ged"
  end
end
