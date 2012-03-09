require 'bing_translator'
require 'yaml'
require 'twitter'

config = YAML.load_file('./config.yaml')
BT_APP_ID = config['BT_APP_ID']

tweets = Twitter.user_timeline("zakuni").map do |tweet| tweet.text end

bt = BingTranslator.new(BT_APP_ID)
tweets.each do |tweet| puts bt.translate(tweet, params = {:to => 'en'}) end
