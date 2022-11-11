module ApplicationHelper
    def check_fields(form_fields, params)
        response_data = {:status => false, :result => {}, :errors => {}}

        # Check if form values are not empty
        form_fields.each do |form_field|
            if params[form_field].strip.empty?
                response_data[:errors][form_field] = "can't be empty."
            else
                # Dont strip password
                response_data[:result][form_field] = ["password", "confirm_password"].include?(form_field) ? params[form_field] : params[form_field].strip
                # Downcase email
                response_data[:result][form_field].downcase! if form_field === "email"
            end
        end

        response_data[:status] = response_data[:errors].empty?

        return response_data
    end
end
