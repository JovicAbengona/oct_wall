class Comment < ApplicationRecord
    def self.get_comment(comment_id)
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            response_data[:result] = ActiveRecord::Base.connection.select_one(
                ActiveRecord::Base.send(:sanitize_sql_array, [
                    "SELECT
                        comments.id AS comment_id, comments.user_id, comments.content, comments.updated_at,
                        users.first_name, users.last_name
                    FROM comments
                    INNER JOIN users ON users.id = comments.user_id
                    WHERE comments.id = ?;", comment_id
                ])
            )

            response_data[:status] = true
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end

    def self.create_comment(params)
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            create_comment = ActiveRecord::Base.connection.insert(
                ActiveRecord::Base.send(:sanitize_sql_array, [
                    "INSERT INTO comments (user_id, message_id, content, created_at, updated_at)
                    VALUES (?, ?, ?, NOW(), NOW());", params[:user_id], params[:message_id], params[:content]
                ])
            )

            if create_comment
                get_comment = self.get_comment(create_comment)

                raise "Error fetching comment" if !get_comment[:status]

                response_data[:status] = true
                response_data[:result]["comment"] = get_comment[:result]
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end

    def self.delete_comment(params)
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            delete_message = ActiveRecord::Base.connection.delete(
                ActiveRecord::Base.send(:sanitize_sql_array, [
                    "DELETE FROM comments WHERE id = ? AND user_id = ?;", params[:comment_id], params[:user_id]
                ])
            )

            if delete_message
                response_data[:status] = true
                response_data[:result]["comment_id"] = params[:comment_id]
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end
end