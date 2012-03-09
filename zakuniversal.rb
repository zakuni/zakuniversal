require 'bing_translator'
require 'yaml'
require 'twitter'
require 'mongo'

config = YAML.load_file('./config.yaml')
BT_APP_ID = config['BT_APP_ID']

tweets = Twitter.user_timeline("zakuni").map do |tweet| 
	tweet.text 
end

@conn = Mongo::Connection.new(config['mongo_server'], config['mongo_port'])
@db = @conn['shelf']
@coll = @db['books']

@coll.find.each { |doc| puts doc.inspect }

bt = BingTranslator.new(BT_APP_ID)
lang = bt.supported_language_codes

tweets.each do |tweet| 
	puts bt.translate(tweet, params = {:to => lang[rand(lang.length)]}) 
end
