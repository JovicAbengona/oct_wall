include ApplicationHelper

class MessagesController < ApplicationController
    before_action :check_user_session

    def index
        # Display homepage

        # Fetch all messages
        @messages = Message.get_messages()[:result]
    end

    def create_message
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            # Validate form values
            response_data = check_fields(["user_id", "content"], params.permit(:user_id, :content))

            # Create message record if form values are valid
            if response_data[:status]
                create_message = Message.create_message(response_data[:result])

                if create_message[:status]
                    response_data[:status]                 = true
                    response_data[:result]["message_html"] = render_to_string :partial => "messages/partials/message", :locals => { :message => create_message[:result] }
                end
            end

        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        render json: response_data
    end

    def update_message
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            # Set array values needed in the model
            form_fields = ["message_id", "user_id", "is_archived"]

            form_fields.push("content") if params["is_archived"].to_i == STATUS[:not_archived]

            # Validate form values
            response_data = check_fields(form_fields, params.permit(:message_id, :user_id, :content, :is_archived))

            # Create message record if form values are valid
            if response_data[:status]
                update_message = Message.update_message(response_data[:result])

                if update_message[:status]
                    response_data[:status]                 = true
                    response_data[:result]["message_html"] = render_to_string :partial => "messages/partials/message", :locals => { :message => update_message[:result] }
                end
            end

        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        render json: response_data
    end

    private
        def check_user_session
            redirect_to "/signin" if !session["id"].present?
        end
end
