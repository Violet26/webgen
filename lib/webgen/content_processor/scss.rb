# -*- encoding: utf-8 -*-

require 'webgen/content_processor/sass'

module Webgen
  class ContentProcessor

    # Processes content in sassy CSS markup (used for writing CSS files) using the +sass+ library.
    module Scss

      # Convert the content in +scss+ markup to CSS.
      def self.call(context)
        options = Webgen::ContentProcessor::Sass.default_options(context).merge(:syntax => :scss)
        context.content = ::Sass::Engine.new(context.content, options).render
        context
      rescue ::Sass::SyntaxError => e
        raise Webgen::RenderError.new(e, 'content_processor.scss', context.dest_node, nil, (e.sass_line if e.sass_line))
      end

    end

  end
end
