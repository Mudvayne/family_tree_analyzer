class GedcomFilesController < ApplicationController
  def delete
    puts "delete"
    GedcomFile.destroy(params[:gedcom_file][:id])
    flash[:success] = "Your tree was deleted successfully!"
    redirect_to root_path
  end

  def go_to_analysis
    if params[:commit]
      delete
      return
    end

    redirect_to analysis_path
  end
end
