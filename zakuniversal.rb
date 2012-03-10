require 'bing_translator'
require 'yaml'
require 'twitter'
require 'mongo'

@conf = YAML.load_file('./config.yaml')
BT_APP_ID = @conf['BT_APP_ID']

@conn = Mongo::Connection.new(@conf['mongo_server'], @conf['mongo_port'])
@db = @conn[@conf['mongo_db']]
@baseColl = @db[@conf['mongo_coll']]
@translatedColl = @db['translatedtweets']

@bt = BingTranslator.new(BT_APP_ID)
@langs = @bt.supported_language_codes

Twitter.configure do |config|
  config.consumer_key = @conf['consumer_key'] 
  config.consumer_secret = @conf['consumer_secret']
  config.oauth_token = @conf['oauth_token']
  config.oauth_token_secret = @conf['oauth_token_secret']
end

def store(tweet)
	if @baseColl.find('tweet_id' => tweet.id).count == 0 then
		@baseColl.insert({'tweet_id' => tweet.id, 'text' => tweet.text})
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
# @translatedColl.insert({'tweet_id' => tweeted.id})

@baseColl.find.each do |tweet|
	text = tweet["text"]
	translated = translate(text)
	puts "#{text}\n[#{translated['lang']}]#{translated['text']}"
end

