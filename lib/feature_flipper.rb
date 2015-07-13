require "flipper/adapters/memory"
class FeatureFlipper
  def initialize
    setup_groups if @flipper.nil?
    @flipper ||= Flipper.new(adapter)
  end

  private

  def setup_groups
    FeatureFlipper.register(:staff) do |actor|
      actor.respond_to?(:staff) && actor.staff?
    end
  rescue Flipper::DuplicateGroup
    Rails.logger.info "Trying to send a duplicate group name"
  end

  def method_missing(m, *args, &block)
    @flipper.__send__(m, *args, &block)
  end

  def self.method_missing(m, *args, &block)
    Flipper.__send__(m, *args, &block)
  end

  def adapter
    if Rails.env.test?
      Flipper::Adapters::Memory.new
    else
      Flipper::Adapters::Redis.new(redis_client)
    end
  end

  def redis_client
    @redis_client ||= Redis::Namespace.new("flipper", redis: $redis)
  end
end
