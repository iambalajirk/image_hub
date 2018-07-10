include Redis::RedisWrapper
include RedisKeys


config = YAML::load_file(File.join(Rails.root, 'config', 'redis.yml'))[Rails.env]

$redis = Redis.new(:host => config["host"], :port => config["port"], :timeout => config["timeout"], :tcp_keepalive => config["keepalive"])

# Add a directory metadata reference for the root folder.
# user_id (Not needed in production we can create the user IDs as and when they sign up!!)
meta = { name: 'me', parent_directory_id: nil, level: 0}
key = directory_metadata_key(Constant::SAMPLE_USER_ID, Constant::SAMPLE_USER_ID)

response = set_value(key, meta.to_json)
p "redis response #{response}"