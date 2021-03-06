# -*- encoding: utf-8 -*-

module Webgen
  class Tag

    # Create a link to a given (A)LCN.
    module Link

      # Return an HTML link to the given (A)LCN.
      def self.call(tag, body, context)
        path = context[:config]['tag.link.path'].to_s
        if (dest_node = context.ref_node.resolve(path, context.dest_node.lang, true))
          context.website.ext.item_tracker.add(context.dest_node, :node_meta_info, dest_node)
          context.dest_node.link_to(dest_node, context.content_node.lang, context[:config]['tag.link.attr'])
        else
          ''
        end
      rescue URI::InvalidURIError => e
        raise Webgen::RenderError.new("Error while parsing path '#{path}': #{e.message}",
                                      "tag.#{tag}", context.dest_node, context.ref_node)
      end

    end

  end
end
