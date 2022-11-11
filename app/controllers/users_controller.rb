include ApplicationHelper

class UsersController < ApplicationController
    before_action :check_user_session, except: [:signout]

    def signup
        # Render signup page
    end
    
    def signin
        # Render signin page
    end

    # Destroy session and redirect to sign in page
    def signout
        reset_session

        redirect_to "/signin"
    end

    # Function for creating user record
    def create_user
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            # Validate form values
            response_data = check_fields(
                ["first_name", "last_name", "email", "password", "confirm_password"],
                params.permit(:first_name, :last_name, :email, :password, :confirm_password)
            )

            # Pass form values to model if valid
            if response_data[:status]
                create_user = User.create_user(response_data[:result])

                # Create user session if create_user is true
                if create_user[:status]
                    user_fields = create_user[:result].keys

                    user_fields.each do |user_field|
                        session[user_field] = create_user[:result][user_field]
                    end
                else
                    response_data[:status] = false
                    response_data[:errors] = create_user[:errors]
                end
            end

        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        render :json => response_data
    end

    # Function for getting user record
    def get_user
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            # Validate form values
            response_data = check_fields(["email", "password"], params.permit(:email, :password))

            # Pass form values to model if valid
            if response_data[:status]
                create_user = User.get_user(response_data[:result])

                # Create user session if create_user is true
                if create_user[:status]
                    user_fields = create_user[:result].keys

                    user_fields.each do |user_field|
                        session[user_field] = create_user[:result][user_field]
                    end
                else
                    response_data[:status] = false
                    response_data[:errors] = create_user[:errors]
                end
            end

        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        render :json => response_data
    end

    private
        # Redirect to homepage if session exists
        def check_user_session
            redirect_to "/messages" if session["id"].present?
        end
end
