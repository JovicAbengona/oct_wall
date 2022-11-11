include ApplicationHelper

class CommentsController < ApplicationController
    def create_comment
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            # Validate form values
            response_data = check_fields(["user_id", "message_id", "content"], params.permit(:user_id, :message_id, :content))

            # Create message record if form values are valid
            if response_data[:status]
                create_comment = Comment.create_comment(response_data[:result])

                if create_comment[:status]
                    response_data[:status] = true
                    response_data[:result]["comment_html"] = render_to_string :partial => "comments/partials/comment", :locals => { :comment => create_comment[:result] }
                end
            end

        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        render json: response_data
    end

    def update_comment
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            # Set array values needed in the model
            form_fields = ["comment_id", "user_id", "is_archived"]

            form_fields.push("content") if params["is_archived"].to_i == STATUS[:not_archived]

            # Validate form values
            response_data = check_fields(form_fields, params.permit(:comment_id, :user_id, :content, :is_archived))

            # Create message record if form values are valid
            if response_data[:status]
                update_message = Comment.update_comment(response_data[:result])

                if update_message[:status]
                    response_data[:status]                 = true
                    response_data[:result]["comment_html"] = render_to_string :partial => "comments/partials/comment", :locals => { :comment => create_comment[:result] }
                end
            end

        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        render json: response_data
    end
end
