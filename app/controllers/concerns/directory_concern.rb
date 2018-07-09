module DirectoryConcern

	def load_directory_configs
		handle_exception do
			@directory_id = directory_is_root? ? user_id : params[:id]
			directory_meta  = get_directory_meta(user_id, @directory_id)

			json_response({:error => ErrorMessages[:directory_not_present]}, :not_found) && return if directory_meta.blank?

			@level = directory_meta[:level]
			@name =  directory_meta[:name]
			@parent_directory_id = directory_meta[:parent_directory_id]
		end
	end

	def check_directory_presence
		handle_exception do
			directory_key = directory_image_id(user_id, directory_id, new_directory_name)
			@new_directory_id = generate_hash(directory_key)

			meta = get_directory_meta(user_id, new_directory_id)
			json_response({:error => ErrorMessages[:directory_exists]}, :conflict) and return if meta.present?
		end
	end

	private

	def directory_is_root?
		params[:id] == "me"
	end

end