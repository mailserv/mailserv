module ActiveScaffold::Actions
  module Sortable
    
    def self.included(base)
      base.helper_method :sort_params
      
      configure_for_sortable(base)
    end
    
    def self.configure_for_sortable(base)
      config = base.active_scaffold_config
      config.list.per_page = 9999 # disable pagination
      
      base.add_active_scaffold_path File.join(RAILS_ROOT, 'vendor', 'plugins', sortable_plugin_name, 'views')
      
      # turn sorting off
      sortable_column = config.sortable.column.to_sym
      force_sort_on(sortable_column, config)
      
      [:list, :update, :create].each do |action_name|
        config.send(action_name).columns.exclude(sortable_column) if config.actions.include?(action_name)
      end
      
    end
    
    def self.force_sort_on(column, config)
      config.columns.each{|c| 
        c.sort = false unless c.name == column 
      }
      config.list.sorting = { column => "asc" }
    end
    
    def self.sortable_plugin_name
      # extract the name of the plugin as installed
      /.+vendor\/plugins\/(.+)\/lib/.match(__FILE__)
      plugin_name = $1
    end
    
    def reorder
      m = active_scaffold_config.model
      column_name = m.connection.quote_column_name(active_scaffold_config.sortable.column)
      
      id_list = params[active_scaffold_tbody_id].map{|i| i.gsub(/[^0-9]/, '').to_i}
      id_list.each_index{|index|
        m.update_all(["#{column_name} = ?", index+1], ["id = ?", id_list[index]])
      }
      render :update do |page|
        page << "ActiveScaffold.stripe('#{active_scaffold_tbody_id}');"
      end
    end
    
  protected
    def sort_params
      [
        "#{active_scaffold_tbody_id}", 
        {
          :tag => "tr", 
          :url => {:action => :reorder, :controller => params[:controller] },
          :format => active_scaffold_config.sortable.format
        }
      ]
    end
  end
  
end
