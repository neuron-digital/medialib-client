module Paperclip
  module Schema
    module Statements
      def remove_attachment(table_name, *attachment_names)
        raise ArgumentError, "Please specify attachment name in your remove_attachment call in your migration." if attachment_names.empty?

        options = attachment_names.extract_options!

        attachment_names.each do |attachment_name|
          COLUMNS.each_pair do |column_name, column_type|
            column_options = options.merge(options[column_name.to_sym] || {})
            if ActiveRecord::VERSION::MAJOR >= 4
              remove_column(table_name, "#{attachment_name}_#{column_name}", column_type, column_options)
            else
              remove_column(table_name, "#{attachment_name}_#{column_name}")
            end
          end
        end
      end
    end
  end
end
