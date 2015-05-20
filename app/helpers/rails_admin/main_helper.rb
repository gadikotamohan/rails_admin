require 'builder'

module RailsAdmin
  module MainHelper
    def rails_admin_form_for(*args, &block)
      options = args.extract_options!.reverse_merge(builder: RailsAdmin::FormBuilder)
      form_for(*(args << options), &block) << after_nested_form_callbacks
    end

    def get_indicator(percent)
      return '' if percent < 0          # none
      return 'info' if percent < 34   # < 1/100 of max
      return 'success' if percent < 67  # < 1/10 of max
      return 'warning' if percent < 84  # < 1/3 of max
      'danger'                # > 1/3 of max
    end

    def get_column_sets(properties)
      sets = []
      property_index = 0
      set_index = 0

      while property_index < properties.length
        current_set_width = 0
        loop do
          sets[set_index] ||= []
          sets[set_index] << properties[property_index]
          current_set_width += (properties[property_index].column_width || 120)
          property_index += 1
          break if current_set_width >= RailsAdmin::Config.total_columns_width || property_index >= properties.length
        end
        set_index += 1
      end
      sets
    end

    def cpu_usage
      "CPU usage #{`grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}'`}"
    end

    def ram_usage
      ram_infos = [ram_used, ram_cache, ram_buffered]
      ram_infos.delete_if{ |s| s.blank? }
      "Ram usage #{ram_infos.join(",")}"
    end

    def ram_used
      `free | awk '/Mem/{printf("used: %.2f%"), $3/$2*100}'`
    end

    def ram_cache
      `free | awk '/buffers\/cache/{printf("buffers: %.2f%"), $4/($3+$4)*100}'`
    end

    def ram_buffered
      `free | awk '/Swap/{printf(", swap: %.2f%"), $3/$2*100}'`
    end
  end
end
