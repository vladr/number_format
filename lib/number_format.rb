# NumberFormat

module NumberFormat # :nodoc:
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def number_format(*args)  # :nodoc:
      options = args.pop if args.last.is_a?(Hash)
      precision = options.delete(:precision)
      stripzero = options.delete(:strip_trailing_zeros)
      delimiter = options.delete(:delimiter)
      separator = options.delete(:separator)
      precision_code = "value = NumberFormat::NumberHelper.number_with_precision(value, :precision => #{precision})" if precision
      stripzero_code = "value = value.sub(/(\\.[^0]*)0+$/, '\\1')" if stripzero
      delimiter_code = "value = NumberFormat::NumberHelper.number_with_delimiter(value, :delimiter => '#{delimiter || ''}', :separator => '#{separator || '.'}')" if delimiter || separator
      undelimit_code = "value = value.gsub('#{delimiter}', '')" if delimiter
      unseparat_code = "value = value.sub('#{separator}', '.')" if separator
      args.each do |attr|
        if precision_code || delimiter_code
          class_eval <<-EOV, __FILE__, __LINE__
            def #{attr}
              if value = read_attribute('#{attr}')
                #{precision_code || ''}
                #{stripzero_code || ''}
                #{delimiter_code || ''}
              end
              value
            end
            def self.format_as_#{attr}(value)
              if value
                #{precision_code || ''}
                #{stripzero_code || ''}
                #{delimiter_code || ''}
              end
              value
            end
          EOV
        end
        ##
        if undelimit_code || unseparat_code
          class_eval <<-EOV, __FILE__, __LINE__
            def #{attr}=(value)
              if value.is_a?(String)
                #{undelimit_code || ''}
                #{unseparat_code || ''}
              end
              write_attribute('#{attr}', value)
            end
          EOV
        end
        ##
        class_eval <<-EOV, __FILE__, __LINE__
          def unformatted_#{attr}
            read_attribute('#{attr}')
          end
          def unformatted_#{attr}=(value)
            write_attribute('#{attr}', value)
          end
        EOV
      end
    end # number_format
  end # ClassMethods

  class NumberHelper
    extend ActionView::Helpers::NumberHelper
  end
end # NumberFormat

ActiveRecord::Base.class_eval do
  include NumberFormat
end
