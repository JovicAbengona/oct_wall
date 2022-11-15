class Comment < ApplicationRecord
    def self.get_comment(comment_id)
        response_data = { :status => false, :result => {}, :error => nil }
    
        begin
            response_data[:result] = ActiveRecord::Base.connection.select_one(
                ActiveRecord::Base.send(:sanitize_sql_array, [
                    "SELECT
                        comments.id AS message_id, comments.user_id, comments.content, comments.updated_at,
                        users.first_name, users.last_name
                    FROM comments
                    INNER JOIN users ON users.id = comments.user_id
                    WHERE comments.id = ?;",
                    comment_id
                ])
            )
    
            response_data[:status] = true
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end

    def self.get_comments
        response_data = { :status => false, :result => {}, :error => nil }
    
        begin
            response_data[:result] = ActiveRecord::Base.connection.exec_query(
                ActiveRecord::Base.send(:sanitize_sql_array, [
                    "SELECT
                        JSON_OBJECTAGG(
                            comments.message_id,
                            (
                                SELECT
                                    JSON_ARRAYAGG(
                                        JSON_OBJECT(
                                            'comment_id', comments_subq.id,
                                            'message_id', comments_subq.message_id,
                                            'user_id', comments_subq.user_id,
                                            'first_name', users_subq.first_name,
                                            'last_name', users_subq.last_name,
                                            'content', comments_subq.content,
                                            'updated_at', comments_subq.updated_at
                                        )
                                    ) AS comments
                                FROM comments AS comments_subq
                                INNER JOIN users AS users_subq ON users_subq.id = comments_subq.user_id
                                WHERE comments_subq.message_id = comments.message_id
                            )
                        ) AS comments
                    FROM comments
                    INNER JOIN users ON users.id = comments.user_id
                    ORDER BY comments.id DESC;"
                ])
            ).to_a
    
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
                    "INSERT INTO comments (user_id, message_id, content, is_archived, created_at, updated_at)
                    VALUES (?, ?, ?, ?, NOW(), NOW());", params[:user_id], params[:message_id], params[:content], STATUS[:not_archived]
                ])
            )

            if create_comment
                response_data[:status] = true
                response_data[:result]["comment"] = self.get_comment(create_comment)
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end

    def self.delete_comment(params)
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            delete_comment = ActiveRecord::Base.connection.delete(
                ActiveRecord::Base.send(:sanitize_sql_array, [
                    "DELETE FROM comments WHERE id = ? AND user_id = ?;", params[:comment_id], params[:user_id]
                ])
            )

            if delete_comment
                response_data[:status] = true
                response_data[:result]["comment_id"] = params[:comment_id]
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end
end
