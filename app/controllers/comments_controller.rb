include ApplicationHelper

class CommentsController < ApplicationController
    before_action :check_user_session

    def create_comment
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            check_fields = check_fields(["content", "message_id"], params.permit(:content, :message_id))

            raise "Input field error. Can't create comment" if !check_fields[:status]

            response_data = Comment.create_comment({
                :user_id    => session["id"],
                :message_id => check_fields[:result]["message_id"],
                :content    => check_fields[:result]["content"]
            })

            if response_data[:status]
                response_data[:result][:comment_html] = render_to_string :partial => "comments/partials/comment_partial", :locals => { :comment => response_data[:result]["comment"] }
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        render json: response_data
    end

    def delete_comment
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            response_data = Comment.delete_comment({
                :user_id    => session["id"],
                :comment_id => params["comment_id"]
            })
        rescue Exception => ex
            response_data[:error] = ex
        end

        render json: response_data
    end

    private
        def check_user_session
            redirect_to "/" if session["id"].nil?
        end
end
