# -*- mode:ruby; coding:utf-8 -*-

require 'test/unit'
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../../lib'))
require 'www/video_scraper'
require 'filecache'
require 'fileutils'

class TestRedTube < Test::Unit::TestCase
  def setup
    @cache_root = '/tmp/test_video_scraper_cache'
    WWW::VideoScraper.configure do |conf|
      conf[:cache] = FileCache.new('TestVideoScraper', @cache_root, 60*60*24)
    end
  end

  def teardown
    # FileUtils.remove_entry_secure(@cache_root, true)
  end

  def test_scrape
    vs = WWW::VideoScraper.scrape('http://www.redtube.com/8415')
    assert_equal 'http://www.redtube.com/8415', vs.page_url
    assert_match %r!http://dl\.redtube\.com/_videos_t4vn23s9jc5498tgj49icfj4678/0000008/Z2XDJA1ZL\.flv!, vs.video_url
    assert_nil vs.thumb_url
    assert_match %r!<object\s+.*</object>!, vs.embed_tag
  end
end