class GedcomFilesController < ApplicationController
  def destroy
    GedcomFile.destroy(params[:gedcom_file][:id])
    flash[:success] = "Your tree was deleted successfully!"
    redirect_to root_path
  end
end
