module DirectoryConcern

	# The root folder for the user will be created when the user signs up!!.
	# Here we will check the root folder and the folder in the request is present or not(using directory_path).
	# recursively check for the folders if the end folder exists or not. Throw error if so.
	# The root directory ID will be by default the user_id.
	def load_parent_directory
		handle_exception do
			byebug
			@parent_directory_id = directory_is_root?(directory_path) ? user_id : directory_id_from_params(directory_path)
			directory_meta  = get_directory_meta(user_id, @parent_directory_id)

			json_response({:error => ErrorMessages[:directory_not_present]}, :not_found) and return if directory_meta.blank?
			true
		end
	end

	def load_directory_configs
		handle_exception do
			@directory_id = directory_is_root?(path) ? user_id : directory_id_from_params(path)
			directory_meta  = get_directory_meta(user_id, @directory_id)

			json_response({:error => ErrorMessages[:directory_not_present]}, :not_found) and return if directory_meta.blank?

			@level = directory_meta[:level]
			@name =  directory_meta[:name]
			@parent_directory_id = directory_meta[:parent_directory_id]
		end
	end

	private

	def directory_is_root? path
		path == ""
	end

	def directory_id_from_params path
		path.split('/')[1]
	end

end