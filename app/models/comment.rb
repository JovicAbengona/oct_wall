class Comment < ApplicationRecord
    def self.get_comment(comment_id)
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            get_comment = ActiveRecord::Base.connection.select_one(
                ActiveRecord::Base.send(:sanitize_sql_array, ["
                    SELECT
                        comments.id, comments.message_id, comments.user_id, comments.content, comments.updated_at,
                        users.first_name, users.last_name
                    FROM comments
                    INNER JOIN users ON users.id = comments.user_id
                    WHERE comments.id = ?;",
                    comment_id
                ])
            )

            response_data[:status] = true
            response_data[:result] = get_comment
        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        return response_data
    end

    def self.create_comment(params)
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            create_comment = ActiveRecord::Base.connection.insert(
                ActiveRecord::Base.send(:sanitize_sql_array, [
                    "INSERT INTO comments (user_id, message_id, content, is_archived, created_at, updated_at) VALUES (?, ?, ?, ?, NOW(), NOW());",
                    params["user_id"], params["message_id"], params["content"].strip, STATUS[:not_archived]
                ])
            )

            raise "Error creating message" if !create_comment

            get_comment = self.get_comment(create_comment)

            raise "Error fetching message" if !get_comment[:status]

            response_data[:status] = true
            response_data[:result] = get_comment[:result]
        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        return response_data
    end

    def self.update_comment(params)
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            set_clause  = "content = ?"
            bind_params = [params["content"]]

            # Change set_clause and bind_params if comment is being deleted
            if params["is_archived"].to_i == STATUS[:archived]
                set_clause  = "is_archived = ?"
                bind_params = [params["is_archived"]]
            end

            bind_params.push(params["comment_id"])

            update_message = ActiveRecord::Base.connection.update(
                ActiveRecord::Base.send(:sanitize_sql_array, ["UPDATE comments SET #{set_clause}, updated_at = NOW() WHERE id = ?;", *bind_params])
            )

            raise "Error updating message" if !update_message

            get_message = self.get_message(params["comment_id"])

            raise "Error fetching message" if !get_message[:status]

            response_data[:status] = true
            response_data[:result] = get_message[:result]
        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        return response_data
    end
end
