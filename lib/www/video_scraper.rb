# -*- mode:ruby; coding:utf-8 -*-

require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'mechanize'
require 'kconv'
require 'json'
require 'uri'
begin
  require 'cgialt' unless defined? CGI
rescue LoadError
  require 'cgi'
end

module WWW
  module VideoScraper
    VERSION = '1.0.5'

    MODULES_NAME = %w(adult_satellites age_sage ameba_vision dailymotion eic_book
                      moro_tube nico_video pornhub pornotube red_tube tube8 veoh
                      you_porn you_tube your_file_host)

    @@modules = MODULES_NAME.map do |name|
      require File.expand_path(File.join(File.dirname(__FILE__), 'video_scraper', name))
      const_get( name.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase } )
    end

    @@options = {
      :logger => nil,
      :cache => nil,
    }

    class << self
      def modules
        @@nodules
      end

      def options
        @@options
      end

      def options=(opts)
        @@options = opts
      end

      def configure(&proc)
        raise ArgumentError, "Block is required." unless block_given?
        yield @@options
      end

      def find_module(url)
        @@modules.find { |mod| mod.valid_url?(url) }
      end

      # 与えられた URL を処理できるモジュールを @@modules から検索して実行する
      def scrape(url, opt = nil)
        opt = @@options.merge(opt || {})
        opt[:logger] ||= logger
        raise StandardError, "url param is requred" unless url

        logger.info "url: #{url}"
        if mod = find_module(url)
          logger.info "found module: #{mod.to_s}"
          return mod.scrape(url, opt)
        end
        logger.info "unsupport url."
        return nil
      rescue TimeoutError, Timeout::Error, Errno::ETIMEDOUT => e
        logger.warn "  Timeout : #{e.to_s}"
        raise TryAgainLater, e.to_s
      rescue OpenURI::HTTPError => e
        raise TryAgainLater, e.to_s if e.to_s.match(/50\d/)
        raise FileNotFound, e.to_s if e.to_s.match(/40\d/)
        raise
      rescue Exception => e
        logger.error "#{e.class}: #{e.to_s}"
        raise e
      end

      private
      def logger
        return @@options[:logger] if @@options[:logger]
        @@options[:logger] = NullLogger.new
      end
    end
  end
end
