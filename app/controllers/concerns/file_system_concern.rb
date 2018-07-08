# We can play with this concern and replace the logic by finding the folder in s3(If storage is s3).
# Replace find_root_directory with an S3 API to find the folders presense.
module FileSystemConcern

	include RedisKeys

	def file_exists? file_id
		key = files_metadata_key(file_id)
		get_value(key)
	end

	def store_image directory, file_name, data
		create_physical_directory(directory)
		create_image_in_directory(directory, file_name, data)
	end

	# This is the directory in the file system where the image is going to recide.
	def create_physical_directory directory
		# Use file Utils and create the directory.
		unless File.directory?(directory)
  		FileUtils.mkdir_p(directory)
		end
	end

	def get_all_image_metas_in_directory user_id, directory_id
		key = image_reference_inside_directory_key_list(user_id, directory_id)
		image_ids = get_all_from_list(key)

		# Getting individual metadata form an array and returning.
		image_ids.map do |image_id|
			key = images_metadata_key(user_id, image_id)
			meta = get_value(key)

			return nil if meta.nil?

			data = {id: image_id, url: "#{IMAGE_LINK}/#{image_id}"}
			data.merge!(JSON.parse(meta).symbolize_keys)
		end.compact
	end

	def get_all_directory_metas_in_directory user_id, directory_id
		key = directory_reference_inside_directory_key_list(user_id, directory_id)
		directory_ids = get_all_from_list(key)

		# Getting individual metadata form an array and returning.
		directory_ids.map do |id|
			key = directory_metadata_key(user_id, id)
			meta = get_value(key)

			return nil if meta.nil?

			data = {id: id,  url: "#{DIRECTORY_LINK}/#{id}"}
			data.merge!(JSON.parse(meta).symbolize_keys)
		end.compact
	end

	def create_image_in_directory directory, file_name, data
		# Open the file stream and write the data.
		Dir.chdir(directory)
		f = File.open(file_name, "w")
		f.write(data)
		f.close
	end

	def get_image_meta user_id, image_id
		key = images_metadata_key(user_id, image_id)
		meta = get_value(key)

		meta.nil? ? meta : JSON.parse(meta).symbolize_keys
	end

	def get_directory_meta user_id, directory_id
		key = directory_metadata_key(user_id, directory_id)
		meta = get_value(key)

		meta.nil? ? meta : JSON.parse(meta).symbolize_keys
	end

	def store_image_meta user_id, image_id, meta
		key = images_metadata_key(user_id, image_id)

		Rails.logger.debug "**storage** **add** **metadata** storing image meta data in redis, key: #{key}"
		set_value(key, meta.to_json)
	end

	def store_directory_meta user_id, directory_id, meta
		key = directory_metadata_key(user_id, directory_id)

		Rails.logger.debug "**storage** **add** **metadata** storing directory meta data in redis, key: #{key}"
		set_value(key, meta.to_json)
	end

	def store_image_ref_to_directory user_id, directory_id, image_id
		set = image_reference_inside_directory_key_set(user_id, directory_id)
		list = image_reference_inside_directory_key_list(user_id, directory_id)

		Rails.logger.debug "**storage** **add** **image** storing image #{image_id} references inside directory, key: #{list}"
		add_to_set(set, image_id) # To search in O(1).
		add_to_list(list, image_id) # To get all the values in the sorted order.
	end

	def store_directory_ref_to_directory user_id, directory_id, new_directory_id
		set = directory_reference_inside_directory_key_set(user_id, directory_id)
		list = directory_reference_inside_directory_key_list(user_id, directory_id)

		Rails.logger.debug "**storage** **add** **directory** storing directory #{new_directory_id} references inside directory, key: #{list}"
		add_to_set(set, new_directory_id) # To search in O(1).
		add_to_list(list, new_directory_id) # To get all the values in the sorted order.
	end

	def remove_image_meta user_id, file_id
		key = images_metadata_key(user_id, file_id)

		Rails.logger.debug "**storage** **remove** **metadata** image meta data in redis, key: #{key}"
		delete_value(key)
	end

	def remove_image_ref_from_directory user_id, directory_id, image_id
		set = image_reference_inside_directory_key_set(user_id, directory_id)
		list = image_reference_inside_directory_key_list(user_id, directory_id)

		Rails.logger.debug "**storage** **remove** **image**  image #{image_id} references inside directory, key: #{list}"
		remove_from_set(set, image_id)
		remove_from_list(list, image_id)
	end

	def remove_directory_ref_from_directory user_id, directory_id, new_directory_id
		set = directory_reference_inside_directory_key_set(user_id, directory_id)
		list = directory_reference_inside_directory_key_list(user_id, directory_id)

		Rails.logger.debug "**storage** **remove** **image**  image #{new_directory_id} references inside directory, key: #{list}"
		remove_from_set(set, new_directory_id)
		remove_from_list(list, new_directory_id)
	end

	def get_directory_path image_id
		dir_1, dir_2 = image_id[0], image_id[1]
		"#{ROOT_FOLDER}/#{dir_1}/#{dir_2}/"
	end

end