module BulkInsert

  # Insert multiple rows into a table.
  #
  #   Post.bulk_insert(["title", "body"], [["Title A", "Body a"], ["Title B", "Body b"]])
  def bulk_insert(column_names, data)
    connection.execute(sql_for_bulk_insert(column_names, data)) unless data.empty?
  end
  
  # Update multiple rows into a table.
  #
  #   Post.bulk_update(["id", "title", "body"], [[1, "Title A", "Body a"], [2, "Title B", "Body b"]])
  #
  # If a row with the right id doesn't exist, it will be created.
  def bulk_update(column_names, data)
    connection.execute(sql_for_bulk_update(column_names, data)) unless data.empty?
  end
  
  def sql_for_bulk_insert(column_names, data)
    quoted_table_name   = connection.quote_table_name(table_name)
    quoted_column_names = quote_column_names(column_names)
    quoted_data         = quote_data(data)
    "INSERT INTO #{quoted_table_name} (#{quoted_column_names.join(',')}) VALUES #{quoted_data.join(',')}"
  end
  
  def sql_for_bulk_update(column_names, data)
    sql = sql_for_bulk_insert(column_names, data)
    column_names.delete(primary_key)
    quoted_column_names = quote_column_names(column_names)
    update_clauses      = quoted_column_names.map {|name| "#{name}=VALUES(#{name})" }
    "#{sql} ON DUPLICATE KEY UPDATE #{update_clauses.join(',')}"
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
