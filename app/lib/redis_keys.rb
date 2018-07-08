module RedisKeys
	include Constant

	def image_reference_inside_directory_key user_id, image_id
		"#{GLOBAL_REDIS_PREFIX}:%{user_id}:IMAGES:%{image_id}" % {user_id: user_id, image_id: image_id}
	end

	def directory_reference_inside_directory_key user_id, directory_id
		"#{GLOBAL_REDIS_PREFIX}:%{user_id}:DIRECTORY:%{directory_id}" % {user_id: user_id, directory_id: directory_id}
	end

	def images_metadata_key user_id, image_id
		"#{GLOBAL_REDIS_PREFIX}:%{user_id}:IMAGES_META:%{image_id}" % {user_id: user_id, image_id: image_id}
	end

	def directory_metadata_key user_id, directory_id
		"#{GLOBAL_REDIS_PREFIX}:%{user_id}:DIRECTORY_META:%{directory_id}" % {user_id: user_id, directory_id: directory_id}
	end

	def get_value key
		$redis.perform_redis_op("get", key)
	end

	def set_value key, val
		$redis.perform_redis_op("set", key, val)
	end

	def delete_value key
		$redis.perform_redis_op("delete", key)
	end

	def is_member? key, val
		$redis.perform_redis_op("sismember", key, val)
	end

	def add_to_set key, val
		$redis.perform_redis_op("sadd", key, val)
	end

	def remove_from_set key, val
		$redis.perform_redis_op("srem", key, val)
	end

	def add_to_list key, val
		$redis.perform_redis_op("lpush", key, val)
	end

	def remove_from_list key, val, all=0
		$redis.perform_redis_op("lrem", key, all, val)
	end

end