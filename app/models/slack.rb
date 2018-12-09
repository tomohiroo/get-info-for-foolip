class Slack
  def notify(info)
    slack_webhook_url = ENV['slack_webhook_url']
    notifier = Slack::Notifier.new slack_webhook_url do
      defaults username: 'Foursquareクローラー'
    end
    notifier.post(
      text: "```#{info}```",
      icon_url: 'https://cdn4.iconfinder.com/data/icons/socialcones/508/FourSquare-512.png'
    )
  end
end
