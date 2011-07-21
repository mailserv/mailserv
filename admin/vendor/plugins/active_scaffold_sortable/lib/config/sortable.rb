
module ActiveScaffold::Config
  class Sortable < Base
    def initialize(core_config)

    end
    
    attr_writer :column
    def column
      @column ||= "position"
    end
    
    attr_writer :format
    def format
      @format ||= '/list\-([0-9]+)\-row$/'
    end
  end
end