class Message < ApplicationRecord
    def self.get_message(message_id)
        response_data = { :status => false, :result => {}, :error => nil }
    
        begin
            response_data[:result] = ActiveRecord::Base.connection.select_one(
                ActiveRecord::Base.send(:sanitize_sql_array, [
                    "SELECT
                        messages.id AS message_id, messages.user_id, messages.content, messages.updated_at,
                        users.first_name, users.last_name
                    FROM messages
                    INNER JOIN users ON users.id = messages.user_id
                    WHERE messages.id = ?;",
                    message_id
                ])
            )
    
            response_data[:status] = true
        rescue Exception => ex
            response_data[:error] = ex
        end
    
        return response_data
    end

    def self.get_messages
        response_data = { :status => false, :result => {}, :error => nil }
    
        begin
            response_data[:result] = ActiveRecord::Base.connection.exec_query(
                ActiveRecord::Base.send(:sanitize_sql_array, [
                    "SELECT
                        messages.id AS message_id, messages.user_id, messages.content, messages.updated_at,
                        users.first_name, users.last_name
                    FROM messages
                    INNER JOIN users ON users.id = messages.user_id
                    ORDER BY message_id DESC;"
                ])
            ).to_a
    
            response_data[:status] = true
        rescue Exception => ex
            response_data[:error] = ex
        end
    
        return response_data
    end

    def self.create_message(params)
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            create_message = ActiveRecord::Base.connection.insert(
                ActiveRecord::Base.send(:sanitize_sql_array, [
                    "INSERT INTO messages (user_id, content, is_archived, created_at, updated_at)
                    VALUES (?, ?, ?, NOW(), NOW());", params[:user_id], params[:content], STATUS[:not_archived]
                ])
            )

            if create_message
                response_data[:status] = true
                response_data[:result]["message"] = self.get_message(create_message)
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end

    def self.delete_message(params)
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            delete_message = ActiveRecord::Base.connection.delete(
                ActiveRecord::Base.send(:sanitize_sql_array, [
                    "DELETE FROM messages WHERE id = ? AND user_id = ?;", params[:message_id], params[:user_id]
                ])
            )

            if delete_message
                response_data[:status] = true
                response_data[:result]["message_id"] = params[:message_id]
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end
end
