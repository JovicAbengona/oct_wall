// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

require('jquery')

Rails.start()
Turbolinks.start()
ActiveStorage.start()

$(document).ready(function(){
    $("body")
        .on("change", "form input, form textarea", removeErrorMessages)

        /* Sign up Feature */
        .on("submit", "#signup_form", submitSignupForm)

        /* Sign in Feature */
        .on("submit", "#signin_form", submitSigninForm)
});

/* This function hides error messages */
function removeErrorMessages(){
    $(this).next("p").html("").attr("hidden");
}

/* This function will send post request for signup_form */
function submitSignupForm(){
    $.post($(this).attr("action"), $(this).serialize(), function(response_data){
        /* response_data - { status, result, errors } */

        if(response_data.status){
            alert("Signed up successfully!");
            /* Redirect to homepage */
            window.location.replace("/messages/");
        }
        else{
            /* Error messages */
            for(let error in response_data.errors){
                $(`#${error}`).next("p").removeAttr("hidden").html(`This ${response_data.errors[error]}`);
            }
        }
    });

    return false
}

/* This function will send post request for signup_form */
function submitSigninForm(){
    $.post($(this).attr("action"), $(this).serialize(), function(response_data){
        /* response_data - { status, result, errors } */

        if(response_data.status){
            /* Redirect to homepage */
            window.location.replace("/messages/");
        }
        else{
            /* Error messages */
            alert("Incorrect email or password");
        }
    });

    return false
}