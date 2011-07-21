module ActionController
  module Resources
    class Resource
      # by overwriting the attr_reader :options, we can parse out a special :active_scaffold flag just-in-time.
      def options_with_as_sortable
        if @options.delete(:active_scaffold_sortable)
          logger.info "active_scaffold_sortable: extending RESTful routes for #{@plural}"
          @options[:collection] ||= {}
          @options[:collection].merge!(:reorder => :post)
        end
        options_without_as_sortable
      end
      
      alias_method_chain :options, :as_sortable
    end
  end
end
