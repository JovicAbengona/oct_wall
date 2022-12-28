include ApplicationHelper

class MessagesController < ApplicationController
    before_action :check_user_session

    # Homepage. Display all messages
    def index
        @messages = Message.get_messages()[:result]
    end

    # Create message
    def create_message
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            check_fields = check_fields(["content"], params.permit(:content))

            raise "Input field error. Can't create message" if !check_fields[:status]

            response_data = Message.create_message({
                :user_id => session["id"],
                :content => check_fields[:result]["content"]
            })

            if response_data[:status]
                response_data[:result][:message_html] = render_to_string :partial => "messages/partials/message_partial", :locals => { :message => response_data[:result]["message"][:result] }
            end

        rescue Exception => ex
            response_data[:error] = ex
        end

        render json: response_data
    end

    def delete_message
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            response_data = Message.delete_message({
                :user_id    => session["id"],
                :message_id => params["message_id"]
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
