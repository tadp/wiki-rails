class GollumRepo < ApplicationController
  require 'gollum-lib'
  Wiki = Gollum::Wiki.new('db/wiki.git')
end
