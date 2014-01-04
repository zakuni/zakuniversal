require 'bing_translator'
require 'yaml'
require 'twitter'
require 'mongo'

@conf = YAML.load_file('./config.yaml')
CLIENT_ID = @conf['CLIENT_ID']
CLIENT_SECRET = @conf['CLIENT_SECRET']

@conn = Mongo::Connection.new(@conf['mongo_server'], @conf['mongo_port'])
@db = @conn[@conf['mongo_db']]
@base_coll = @db[@conf['mongo_coll']]
@translated_coll = @db['translatedtweets']

@bt = BingTranslator.new(CLIENT_ID, CLIENT_SECRET)
@langs = @bt.supported_language_codes

puts @base_coll.find().limit(-1).skip(rand(@base_coll.count)).next

Twitter.configure do |config|
  config.consumer_key = @conf['consumer_key'] 
  config.consumer_secret = @conf['consumer_secret']
  config.oauth_token = @conf['oauth_token']
  config.oauth_token_secret = @conf['oauth_token_secret']
end

def store(tweet)
	if @base_coll.find('tweet_id' => tweet.id).count == 0 then
		@base_coll.insert({'tweet_id' => tweet.id, 'text' => tweet.text, 'random' => rand})
		puts "stored"
	else
		puts "already stored"
	end
end

def translate(text)
	lang = @langs[rand(@langs.length)]
	{"lang" => lang, "text" => @bt.translate(text, parmas = {:to => lang})}
end

base_tweets = Twitter.user_timeline("zakuni")
base_tweets.each do |tweet| 
	store(tweet)
end

# tweeted = Twitter.update("nemui")
# @translated_coll.insert({'tweet_id' => tweeted.id})

@base_coll.find.each do |base_tweet|
	text = base_tweet["text"]
	translated = translate(text)
	puts "#{text}\n[#{translated['lang']}]#{translated['text']}"
end
