# We can play with this concern and replace the logic by finding the folder in s3(If storage is s3).
# Replace find_root_directory with an S3 API to find the folders presense.
module FileSystemConcern

	include RedisKeys

	def file_exists? file_id
		key = files_metadata_key(file_id)
		get_value(key)
	end

	# def find_root_directory user_id, directories
	# 	current_directory_id = directories.first

	# 	directories.each_with_index do |directory_id, index|
	# 		response = find_folder_in_current_directory(user_id, current_directory_id, directory_id)
	# 		return false unless response
	# 		current_directory_id = directory_id
	# 	end

	# 	current_directory_id
	# end

	# def find_folder_in_current_directory(user_id, current_directory_id, directory_id)
	# 	key = directory_images_key(user_id, current_directory_id)
	# 	is_member?(key, directory_id)
	# 	# $redis.perform_redis_op("sismember", key, directory_id)
	# end

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

		meta.nil? ? meta : JSON.parse(meta).stringify_keys
	end

	def get_directory_meta user_id, directory_id
		key = directory_metadata_key(user_id, directory_id)
		meta = get_value(key)

		meta.nil? ? meta : JSON.parse(meta).stringify_keys
	end

	def store_image_meta user_id, image_id, meta
		key = images_metadata_key(user_id, image_id)

		Rails.logger.debug "**storage** **add** **metadata** storing image meta data in redis, key: #{key}"
		set_value(key, meta.to_json)
	end

	def store_directory_meta directory_id, meta
		key = directory_metadata_key(user_id, directory_id)

		Rails.logger.debug "**storage** **add** **metadata** storing directory meta data in redis, key: #{key}"
		set_value(key, meta.to_json)
	end

	def store_image_ref_to_directory user_id, directory_id, image_id
		key = image_reference_inside_directory_key(user_id, directory_id)

		Rails.logger.debug "**storage** **add** **image** storing image #{image_id} references inside directory, key: #{key}"
		add_to_set(key, image_id) # To search in O(1).
		add_to_list(key, image_id) # To get all the values in the sorted order.
	end

	def remove_image_meta user_id, file_id
		key = images_metadata_key(user_id, file_id)

		Rails.logger.debug "**storage** **remove** **metadata** image meta data in redis, key: #{key}"
		delete_value(key)
	end

	def remove_image_ref_from_directory user_id, directory_id, image_id
		key = image_reference_inside_directory_key(user_id, directory_id)

		Rails.logger.debug "**storage** **remove** **image**  image #{image_id} references inside directory, key: #{key}"
		remove_from_set(key, image_id)
		remove_from_list(key, image_id)
	end

	def create_file final_dir, file_hash
	end

	def get_directory_path image_id
		dir_1, dir_2 = image_id[0], image_id[1]
		"#{ROOT_FOLDER}/#{dir_1}/#{dir_2}/"
	end

end