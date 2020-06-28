#!/usr/bin/env ruby

require 'atomutil'

USERNAME    = ARGV[0]
BLOG_DOMAIN = ARGV[1]
API_KEY     = ARGV[2]

feed_uri = "https://blog.hatena.ne.jp/#{USERNAME}/#{BLOG_DOMAIN}/atom/entry"

auth = Atompub::Auth::Wsse.new(
  username: USERNAME,
  password: API_KEY
)

client = Atompub::Client.new(auth: auth)

entries = []
loop do
  puts feed_uri
  feed = client.get_feed(feed_uri)
  entries += feed.entries.select { |e| e.control.draft == 'no' }
  if feed.next_link
    feed_uri = feed.next_link
  else
    break
  end
  sleep 1
end

entries = entries.sort do |a, b|
  ret =  0 if a.updated == b.updated
  ret =  1 if a.updated <  b.updated
  ret = -1 if a.updated >  b.updated
  ret
end

entries.each do |entry|
  next if entry.control.draft == 'yes'
  puts "#{entry.updated} [#{entry.title}](#{entry.alternate_link})"
end
