module Redis::RedisWrapper

	Redis.class_eval do
	  def perform_redis_op(operator, *args)
	    self.send(operator, *args)
	  rescue Redis::BaseError => e
	    Rails.logger.error "Error in performing redis op :#{operator}, error :#{e}"
	  end
	end

end