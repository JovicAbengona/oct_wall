class User < ApplicationRecord
    def self.create_user(params)
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            # Do further validation for first_name and last_name
            ["first_name", "last_name"].each do |form_field|
                response_data[:errors][form_field] = "must not contain a number or special character" if params[form_field] =~ /[^a-zA-Z'\s]/
            end

            # Do further validation for email
            response_data[:errors]["email"] = "email is invalid" if !(params["email"][/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i])
            response_data[:errors]["email"] = "email is already registered" if ActiveRecord::Base.connection.select_one(
                                                                                ActiveRecord::Base.send(:sanitize_sql_array, ["SELECT id FROM users WHERE email = ?;", params["email"]])
                                                                            )

            # Do further validation for password and confirm_password
            response_data[:errors]["password"]         = "must be at least 6 characters" if params["password"].length < 6
            response_data[:errors]["confirm_password"] = "doesn't match with password" if params["password"] != params["confirm_password"]

            # Create user record if there are no errors
            if !response_data[:errors].any?
                create_user = ActiveRecord::Base.connection.insert(
                    ActiveRecord::Base.send(:sanitize_sql_array, [
                        "INSERT INTO users (first_name, last_name, email, password, created_at, updated_at) VALUES (?, ?, ?, MD5(?), NOW(), NOW());", 
                        params["first_name"], params["last_name"], params["email"], params["password"]
                    ])
                )

                raise "Error creating user" if !create_user

                response_data[:status] = true
                response_data[:result] = {
                    "id"         => create_user,
                    "first_name" => params["first_name"],
                    "last_name"  => params["last_name"],
                    "email"      => params["email"],
                }
            end

        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        return response_data
    end

    def self.get_user(params)
        response_data = {:status => false, :result => {}, :errors => {}}

        begin
            get_user = ActiveRecord::Base.connection.select_one(
                ActiveRecord::Base.send(:sanitize_sql_array, ["SELECT id, first_name, last_name, email FROM users WHERE email = ? AND password = MD5(?);", params["email"], params["password"]])
            )

            # Check if user record exists based on email and password
            if get_user
                response_data[:status] = true
                response_data[:result] = get_user
            end
        rescue Exception => ex
            response_data[:status]     = false
            response_data[:errors][ex] = ex
        end

        return response_data
    end
end
