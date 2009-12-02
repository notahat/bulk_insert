module BulkInsert

  # Insert multiple rows into a table.
  #
  #   Post.bulk_insert(["title", "body"], [["Title A", "Body a"], ["Title B", "Body b"]])
  def bulk_insert(column_names, data, options = {})
    connection.execute(sql_for_bulk_insert(column_names, data, options)) unless data.empty?
  end
  
  # Update multiple rows into a table.
  #
  #   Post.bulk_update(["id", "title", "body"], [[1, "Title A", "Body a"], [2, "Title B", "Body b"]])
  #
  # If a row with the right id doesn't exist, it will be created.
  def bulk_update(column_names, data)
    connection.execute(sql_for_bulk_update(column_names, data)) unless data.empty?
  end
  
  def sql_for_bulk_insert(column_names, data, options = {})
    quoted_table_name   = connection.quote_table_name(table_name)
    quoted_column_names = quote_column_names(column_names)
    quoted_data         = quote_data(data)
    
    sql = "INSERT INTO #{quoted_table_name} (#{quoted_column_names.join(',')}) VALUES #{quoted_data.join(',')}"
    if options[:on_duplicate_key_update]
      update_clauses = options[:on_duplicate_key_update].map {|name| "#{name}=VALUES(#{name})" }
      sql << " ON DUPLICATE KEY UPDATE #{update_clauses.join(',')}"
    end
    sql
  end
  
  def sql_for_bulk_update(column_names, data)
    sql_for_bulk_insert(column_names, data, :on_duplicate_key_update => column_names - [primary_key])
  end
  
private

  def quote_column_names(names)
    names.map {|name| connection.quote_column_name(name) }
  end
  
  def quote_data(data)
    data.map do |row|
      quoted_values = row.map {|value| connection.quote(value) }
      "(#{quoted_values.join(',')})"
    end
  end
    
end

ActiveRecord::Base.extend(BulkInsert)
