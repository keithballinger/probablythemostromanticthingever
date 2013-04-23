require 'yaml'
require 'erb'
require 'sinatra'

all = Hash.new(YAML::load(ERB.new(IO.read('./config/application.yml')).result)['default'])
APP_CONFIG = all['default'].merge(defined?(RACK_ENV) ? all[RACK_ENV] : all[''])
