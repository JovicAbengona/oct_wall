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

        /* Messages Feature */
        .on("submit", "#create_message_form", submitCreateMessageForm)
        .on("click", ".edit_message_btn", populateEditDeleteForm)
        .on("blur", ".message_content", submitEditMessageForm)
        .on("click", ".delete_message_btn", submitDeleteMessageForm)

        /* Comments Feature */
        .on("submit", ".create_comment_form", submitCreateCommentForm)
        .on("click", ".edit_comment_btn", populateEditDeleteCommentForm)
        .on("blur", ".comment_content", submitEditCommentForm)
        .on("click", ".delete_comment_btn", submitDeleteCommentForm)
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

/* This function will send post request for create_message_form */
function submitCreateMessageForm(){
    $.post($(this).attr("action"), $(this).serialize(), function(response_data){
        /* response_data - { status, result, errors } */
        if(response_data.status){
            $("#create_message_form")[0].reset();

            /* Remove no messages element */
            if($("#messages_list").children("h4")){
                $("#messages_list").children("h4").remove();
            }

            /* Render HTML for message */
            $("#messages_list").prepend(response_data.result.message_html);
        }
        else{
            /* Error messages */
            for(let error in response_data.errors){
                $(`#message_${error}`).next("p").removeAttr("hidden").html(`This ${response_data.errors[error]}`);
            }
        }
    });

    return false
}

/* Prepopulate form values for edit/delete message feature */
function populateEditDeleteForm(){
    const form            = $("#update_message_form");
    const message_id      = $(this).data("message_id");
    const message_element = $(`#message_content_${message_id}`);

    /* Make element editable */
    message_element.attr("contenteditable", true);
    message_element.focus();

    /* Update form values */
    form.children('input[name="message_id"]').val(message_id);
    form.children('input[name="is_archived"]').val(parseInt($(this).data('is_archive')));
}

/* This function will send post request for update_message_form */
function submitEditMessageForm(){
    const form            = $("#update_message_form");
    const message_content = $(this);

    /* Disable content editing */
    message_content.attr("contenteditable", false);

    /* Update form values */
    form.children('input[name="content"]').val($(this)[0].innerHTML);

    $.post(form.attr("action"), form.serialize(), function(response_data){
        /* response_data - { status, result, errors } */
        if(response_data.status){
            /* Render HTML */
            $(`#message_block_${response_data.result.message_id}`).replaceWith(response_data.result.message_html);
        }
        else{
            /* Error messages */
            for(let error in response_data.errors){
                message_content.next("p").removeAttr("hidden").html(`This ${response_data.errors[error]}`);
            }
        }
    });
}

/* This wil send a POST request to delete a message */
function submitDeleteMessageForm(){
    const form       = $("#update_message_form");
    const message_id = $(this).data("message_id");

    /* Update form values */
    form.children('input[name="message_id"]').val(message_id);
    form.children('input[name="is_archived"]').val(parseInt($(this).data('is_archive')));

    if(confirm("Are you sure you want to delete this message?")){
        $.post(form.attr("action"), form.serialize(), function(response_data){
            /* response_data - { status, result, errors } */
            if(response_data.status){
                /* Render/Remove HTML */
                $(`#message_block_${response_data.result.message_id}`).remove();
            }
            else{
                /* Error messages */
                alert("Unable to delete message.")
            }
        });
    }
}

/* This will send a POST request to create a comment */
function submitCreateCommentForm(){
    $.post($(this).attr("action"), $(this).serialize(), function(response_data){
        /* response_data - { status, result, errors } */
        if(response_data.status){
            /* Remove no messages element */
            if($(`#comments_list_${response_data.result.message_id}`).children("h4")){
                $(`#comments_list_${response_data.result.message_id}`).children("h4").remove();
            }

            /* Render HTML for message */
            $(`#comments_list_${response_data.result.message_id}`).prepend(response_data.result.comment_html);
        }
        else{
            /* Error messages */
            for(let error in response_data.errors){
                $(`#comment_message_content_${response_data.result.message_id}`).next("p").removeAttr("hidden").html(`This ${response_data.errors[error]}`);
            }
        }
    });

    return false
}

/* Prepopulate form values for edit/delete comment feature */
function populateEditDeleteCommentForm(){
    const form            = $("#update_comment_form");
    const comment_id      = $(this).data("comment_id");
    const comment_element = $(`#comment_content_${comment_id}`);

    /* Make element editable */
    comment_element.attr("contenteditable", true);
    comment_element.focus();

    /* Update form values */
    form.children('input[name="comment_id"]').val(comment_id);
    form.children('input[name="is_archived"]').val(parseInt($(this).data('is_archive')));
}

/* This function will send post request for update_comment_form */
function submitEditCommentForm(){
    const form            = $("#update_comment_form");
    const comment_content = $(this);

    /* Disable content editing */
    comment_content.attr("contenteditable", false);

    /* Update form values */
    form.children('input[name="content"]').val($(this)[0].innerHTML);

    $.post(form.attr("action"), form.serialize(), function(response_data){
        /* response_data - { status, result, errors } */
        if(response_data.status){
            /* Render HTML for message */
            $(`#comments_list_${response_data.result.message_id}`).prepend(response_data.result.comment_html);
        }
        else{
            /* Error messages */
            for(let error in response_data.errors){
                comment_content.next("p").removeAttr("hidden").html(`This ${response_data.errors[error]}`);
            }
        }
    });
}

/* This wil send a POST request to delete a message */
function submitDeleteCommentForm(){
    const form       = $("#update_comment_form");
    const comment_id = $(this).data("comment_id");

    /* Update form values */
    form.children('input[name="comment_id"]').val(comment_id);
    form.children('input[name="is_archived"]').val(parseInt($(this).data('is_archive')));

    if(confirm("Are you sure you want to delete this message?")){
        $.post(form.attr("action"), form.serialize(), function(response_data){
            /* response_data - { status, result, errors } */
            if(response_data.status){
                /* Render/Remove HTML */
                $(`#comment_block_${response_data.result.comment_id}`).remove();
            }
            else{
                /* Error messages */
                alert("Unable to delete message.")
            }
        });
    }
}