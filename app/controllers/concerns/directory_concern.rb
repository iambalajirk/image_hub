module DirectoryConcern

	def load_directory_configs
		handle_exception do
			@directory_id = directory_is_root? ? user_id : params[:id]
			directory_meta  = get_directory_meta(user_id, @directory_id)

			json_response({:error => ErrorMessages[:directory_not_present]}, :not_found) and return if directory_meta.blank?

			@level = directory_meta[:level]
			@name =  directory_meta[:name]
			@parent_directory_id = directory_meta[:parent_directory_id]
		end
	end

	private

	def directory_is_root?
		params[:id] == "me"
	end

end