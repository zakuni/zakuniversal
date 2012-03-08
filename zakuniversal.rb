require 'bing_translator'
require 'yaml'

config = YAML.load_file('./config.yaml')
BT_APP_ID = config['BT_APP_ID']

bt = BingTranslator.new(BT_APP_ID)
puts bt.translate('hello', params = {:to => 'ja'})
