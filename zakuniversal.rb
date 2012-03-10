require 'bing_translator'
require 'yaml'
require 'twitter'
require 'mongo'

config = YAML.load_file('./config.yaml')
BT_APP_ID = config['BT_APP_ID']

@conn = Mongo::Connection.new(config['mongo_server'], config['mongo_port'])
@db = @conn[config['mongo_db']]
@coll = @db[config['mongo_coll']]

bt = BingTranslator.new(BT_APP_ID)
lang = bt.supported_language_codes

tweets = Twitter.user_timeline("zakuni")

def store(tweet)
	if @coll.find('tweet_id' => tweet.id).count == 0 then
		@coll.insert({'tweet_id' => tweet.id, 'text' => tweet.text})
	else
		puts "already stored"
	end
end

tweets.each do |tweet| 
	store(tweet)
	puts bt.translate(tweet.text, params = {:to => lang[rand(lang.length)]}) 
end

@coll.find.each do |doc|
	puts doc.inspect 
end
