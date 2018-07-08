# Util for calling the File commands. This will act as a contract between ImageHub and the external storage.
# We can replace the local store with the S3 upload if we want to.
module StorageConcern
	include Constant
	

	def check_image_presence
		handle_exception do
			byebug
			image_key = image_unique_id(user_id, parent_directory_id, file_name)
			image_id = generate_hash(image_key)

			meta = get_image_meta(user_id, image_id)

			# Raising conflict if there is another image with the same file name.
			# We can handle this differently too. Rename the original file with (1) suffix.
			json_response({:error => ErrorMessages[:image_exists]}, :conflict) and return if meta.present?
			true
		end
	end

	def create_image
		byebug
		# generating the unique hash. Store this as an instance attribute in check_image_presence, we can avoid this step.
		image_key = image_unique_id(user_id, parent_directory_id, file_name)
		image_id = generate_hash(image_key)
	 	
	 	# final directory path where image is going to reside.
		directory = get_directory_path(image_id)
		# Store the image, directory reference and the meta information.
		store_image_meta(user_id, image_id, populate_image_metadata)
		store_image_ref_to_directory(user_id, parent_directory_id, image_id) # This is a virtual reference.
		store_image(directory, image_id, image)

		image_id
	rescue => error
		# Remove the stored metadata if there are any errors. So, there won't be any absurd behaviours.
		byebug
		remove_image_meta(user_id, image_id)
		remove_image_ref_from_directory(user_id, parent_directory_id, image_id)

		raise error
	end

	private

	def image_unique_id user_id, parent_directory_id, file_name
		"%{user_id}/%{parent_directory_id}/%{file_name}" % {user_id: user_id, parent_directory_id: parent_directory_id, file_name: file_name}
	end

	def generate_hash keys
		Digest::MD5.hexdigest keys
	end

	# def file_with_extension file_id, extension
	# 	"%{file}.%{extension}" % {file: file, extension: extension}
	# end

	def populate_image_metadata
		{
			extension: extension,
			name: file_name,
			dimension: dimension,
			directory_id: parent_directory_id
		}
	end

	def populate_directory_metadata level
		{
			name: directory_name,
			parent_directory_id: parent_directory_id,
			level: level 
		}
	end

end