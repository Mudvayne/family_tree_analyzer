class StaticPagesController < ApplicationController
	def home
		@gedcom_file = GedcomFile.new
		fill_trees
	end

	def upload
		post = post_params
		@gedcom_file = GedcomFile.new({
			:data => post[:data].read,
			:filename => post[:filename],
			:user_id => current_user.id
		})
		
		if @gedcom_file.save then
			flash[:success] = "You have successfully uploaded #{post[:filename]}."
			redirect_to root_path
		else
			fill_trees
			render 'home'
		end
	end

	def rename
		@gedcom_file = current_user.gedcom_files.find params[:id]
		@gedcom_file.filename = params[:name]
		@gedcom_file.save
		fill_trees
		render 'home'
	end

	private
	def post_params
		params.require(:gedcomfile).permit(:filename, :data)
	end

	def fill_trees
		if current_user != nil
			@trees = current_user.gedcom_files.order(:filename)
		end
	end

end