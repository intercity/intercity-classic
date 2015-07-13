namespace :sidekiq do
  desc "Testing"
  task monitoring: :environment do
    queue_size = Sidekiq::Queue.new.size
    last_size = $redis.get("queue_size").to_i || 0
    problem_mode = $redis.get("sidekiq_problem_mode")

    if queue_size >= last_size && queue_size != 0
      SlackSidekiqNotifier.new.send_warning(queue_size)
      $redis.set("sidekiq_problem_mode", true)
    elsif problem_mode == "true"
      SlackSidekiqNotifier.new.send_solved(queue_size)
      $redis.set("sidekiq_problem_mode", false)
    end
    $redis.set("queue_size", queue_size)
  end
end

class SlackSidekiqNotifier
  def initialize(url = "https://hooks.slack.com/services/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")
    @url = url
    @notifier = Slack::Notifier.new url
  end

  def send_warning(items_in_queue)
    @notifier.ping "",
      username: "Sidekiq monitor",
      channel: "#intercity",
      icon_url: "http://www.mikeperham.com/wp-content/uploads/2014/09/logo.png",
      attachments: [{
        color: "danger",
        text: "Looks like Sidekiq is not picking up jobs.",
        fallback: "Looks like Sidekiq is not picking up jobs",
        fields: [
          { title: "Environment", value: "#{Rails.env}", short: true },
          { title: "Items in queue", value: items_in_queue, short: true }
        ]
      }]
  end

  def send_solved(items_in_queue)
    @notifier.ping "",
      username: "Sidekiq monitor",
      channel: "#intercity",
      icon_url: "http://www.mikeperham.com/wp-content/uploads/2014/09/logo.png",
      attachments: [{
        color: "good",
        text: "Sidekiq is picking up jobs again. Yay! :tada:",
        fallback: "Sidekiq is picking up jobs again. Yay!",
        fields: [
          { title: "Environment", value: "#{Rails.env}", short: true },
          { title: "Items still in queue", value: items_in_queue, short: true }
        ]
      }]
  end
end
