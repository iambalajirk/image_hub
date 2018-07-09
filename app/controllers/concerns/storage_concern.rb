# Util for calling the File commands. This will act as a contract between ImageHub and the external storage.
# We can replace the local store with the S3 upload if we want to.
module StorageConcern
	include Constant

	def create_directory
		directory_meta = populate_directory_metadata

		store_directory_meta(user_id, new_directory_id, directory_meta)
		store_directory_ref_to_directory(user_id, directory_id, new_directory_id)

		{id: new_directory_id}.merge!(directory_meta)
	rescue => error
		# Remove the stored metadata if there are any errors. So, there won't be any absurd behaviours.
		remove_directory_meta(user_id, new_directory_id)
		remove_directory_ref_from_directory(user_id, directory_id, new_directory_id)

		raise error
	end

	def create_image
	 	# final directory path where image is going to reside.
		directory = get_directory_path(image_id)

		# Store the image, directory reference and the meta information.
		store_image_meta(user_id, image_id, populate_image_metadata)
		store_image_ref_to_directory(user_id, directory_id, image_id) # This is a virtual reference.
		store_image(directory, image_id, image)

		{ id: image_id, directory_id: directory_id, name: file_name}
	rescue => error
		# Remove the stored metadata if there are any errors. So, there won't be any absurd behaviours.
		remove_image_meta(user_id, image_id)
		remove_image_ref_from_directory(user_id, directory_id, image_id)

		raise error
	end

	def load_directory_contents
		handle_exception do
			@images = image_metas_in_directory(user_id, directory_id)
			@directories = directory_metas_in_directory(user_id, directory_id)
		end
	end

	private

	def image_unique_id user_id, directory_id, file_name
		"%{user_id}/%{directory_id}/%{file_name}" % {user_id: user_id, directory_id: directory_id, file_name: file_name}
	end

	def directory_image_id user_id, parent_directory_id, directory_name
		"%{user_id}/%{parent_directory_id}/%{directory_name}" % {user_id: user_id, parent_directory_id: parent_directory_id, directory_name: directory_name}
	end

	def generate_hash keys
		Digest::MD5.hexdigest keys
	end

	def populate_image_metadata
		{
			extension: extension,
			name: file_name,
			width: width,
			height: height,
			directory_id: directory_id
		}
	end

	def populate_directory_metadata 
		{
			name: new_directory_name,
			level: level + 1,
			parent_directory_id: directory_id
		}
	end

end