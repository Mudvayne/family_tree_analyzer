class GedcomFilesController < ApplicationController
  def delete
    GedcomFile.destroy(params[:id])
    flash[:success] = "Your tree was deleted successfully!"
    redirect_to root_path
  end

  def go_to_analysis
    redirect_to filter_path(params[:id]), status: :found
  end
end
