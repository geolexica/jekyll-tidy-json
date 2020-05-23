require "jekyll"
require "json"

require_relative "tidy_json/version"

module Jekyll
  module TidyJSON
    class Processor
      def initialize(config)
        parse_plugin_config config.fetch("tidy_json", {})
      end

      def should_tidy?(path)
        enabled? && File.extname(path).downcase == ".json"
      end

      def tidy_page_or_document(page_or_document)
        if should_tidy?(page_or_document.relative_path)
          tidy_page_or_document!(page_or_document)
        end
      end

      def tidy_page_or_document!(page_or_document)
        path = page_or_document.relative_path

        Jekyll.logger.debug("Tidy up JSON:", path)
        page_or_document.output = tidy_string(page_or_document.output)
      end

      def tidy_string(string)
        json = JSON.parse(string)
        meth = self.pretty? ? :pretty_generate : :fast_generate

        JSON.public_send meth, json
      end

      def pretty?
        !!@pretty
      end

      def enabled?
        !!@enabled
      end

      private

      def parse_plugin_config(pc)
        @enabled = pc.fetch("enabled", true)
        @pretty = pc.fetch("pretty", false)
      end
    end
  end
end

Jekyll::Hooks.register :documents, :post_render do |doc|
  Jekyll::TidyJSON::Processor.new(doc.site.config).tidy_page_or_document(doc)
end

Jekyll::Hooks.register :pages, :post_render do |page|
  Jekyll::TidyJSON::Processor.new(page.site.config).tidy_page_or_document(page)
end
