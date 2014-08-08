class AdminController < ApplicationController
  def index
    @gedcom_files = GedcomFile.all
  end

  def gedcom_files_archive
    #response.headers["Content-Type"] = "application/zip"
    #response.headers["Content-Disposition"] = 'attachment; filename="GedcomFiles.zip"'
    send_data GedcomFile.create_zip_archive, filename: "GedcomFiles.zip", type: "application/zip"
  end

  def download_gedcom_file
    gedcom_file = GedcomFile.find(params[:id])
    #response.headers["Content-Type"] = "application/text"
    #response.headers["Content-Disposition"] = 'attachment; filename="' + gedcom_file.filename_with_extension + '"'
    send_data gedcom_file.data, filename: gedcom_file.filename_with_extension, type: "text/plain"
  end

  def delete_gedcom_file
    GedcomFile.destroy params[:id]
    flash["success"] = "Gedcom file deleted"
    redirect_to :action => 'index'
  end
end
