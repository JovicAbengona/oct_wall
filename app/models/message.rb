class Message < ApplicationRecord
    def self.get_messages
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            get_messages = ActiveRecord::Base.connection.exec_query(
                ActiveRecord::Base.send(:sanitize_sql_array, ["
                    SELECT
                        messages.id, messages.user_id, messages.content, messages.updated_at,
                        users.first_name, users.last_name,
                        CASE
                            WHEN comments.id IS NOT NULL
                                THEN
                                    JSON_ARRAYAGG(
                                        JSON_OBJECT(
                                            'id', comments.id,
                                            'user_id', comments.user_id,
                                            'content', comments.content,
                                            'updated_at', comments.updated_at,
                                            'first_name', comments_users.first_name,
                                            'last_name', comments_users.last_name
                                        )
                                    )
                            ELSE NULL
                        END AS comments
                    FROM messages
                    INNER JOIN users ON users.id = messages.user_id
                    LEFT JOIN comments ON comments.message_id = messages.id AND comments.is_archived != 1
                    LEFT JOIN users AS comments_users ON comments_users.id = comments.user_id
                    WHERE messages.is_archived != 1
                    GROUP BY messages.id
                    ORDER BY messages.id DESC;", STATUS[:archived], STATUS[:archived]
                ])
            ).to_a

            response_data[:status] = true
            response_data[:result] = get_messages
        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        return response_data
    end

    def self.get_message(message_id)
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            get_message = ActiveRecord::Base.connection.select_one(
                ActiveRecord::Base.send(:sanitize_sql_array, ["
                    SELECT
                        messages.id, messages.user_id, messages.content, messages.updated_at,
                        users.first_name, users.last_name
                    FROM messages
                    INNER JOIN users ON users.id = messages.user_id
                    WHERE messages.id = ?;",
                    message_id
                ])
            )

            response_data[:status] = true
            response_data[:result] = get_message
        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        return response_data
    end

    def self.create_message(params)
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            create_message = ActiveRecord::Base.connection.insert(
                ActiveRecord::Base.send(:sanitize_sql_array, [
                    "INSERT INTO messages (user_id, content, is_archived, created_at, updated_at) VALUES (?, ?, ?, NOW(), NOW());",
                    params["user_id"], params["content"].strip, STATUS[:not_archived]
                ])
            )

            raise "Error creating message" if !create_message

            get_message = self.get_message(create_message)

            raise "Error fetching message" if !get_message[:status]

            response_data[:status] = true
            response_data[:result] = get_message[:result]
        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        return response_data
    end

    def self.update_message(params)
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            set_clause  = "content = ?"
            bind_params = [params["content"]]

            # Change set_clause and bind_params if message is being deleted
            if params["is_archived"].to_i == STATUS[:archived]
                set_clause  = "is_archived = ?"
                bind_params = [params["is_archived"]]
            end

            bind_params.push(params["message_id"])

            update_message = ActiveRecord::Base.connection.update(
                ActiveRecord::Base.send(:sanitize_sql_array, ["UPDATE messages SET #{set_clause}, updated_at = NOW() WHERE id = ?;", *bind_params])
            )

            raise "Error updating message" if !update_message

            get_message = self.get_message(params["message_id"])

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
