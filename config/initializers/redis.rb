$redis = Redis::Namespace.new("intercity_#{Rails.env}", redis: Redis.new)
