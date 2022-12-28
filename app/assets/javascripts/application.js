// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

//= require jquery

$(document).ready(function(){
    $("body")
        .on("change", "form input, form textarea", removeErrorMessages)

        /* Sign up Feature */
        .on("submit", "#signup_form", submitSignupForm)

        /* Sign in Feature */
        .on("submit", "#signin_form", submitSigninForm)

        /* Messages Feature */
        .on("submit", "#create_message", submitCreateMessageForm)
        .on("click", ".delete_message", submitDeleteMessageForm)
        
        /* Comments Feature */
        .on("click", ".create_comment", submitCreateCommentForm)
        .on("click", ".delete_comment", submitDeleteCommentForm)
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
            window.location.href = "/messages/";
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
            window.location.href = "/messages/";
        }
        else{
            /* Error messages */
            alert("Incorrect email or password");
        }
    }, "json");

    return false;
}

function submitCreateMessageForm(){
    $.post($(this).attr("action"), $(this).serialize(), function(response_data){
        if(response_data.status){
            $("#messages_html").prepend(response_data.result.message_html);
        }
        else{
            alert(response_data.error);
        }

        $("#create_message")[0].reset();
    });

    return false
}

function submitDeleteMessageForm(){
    if(confirm("Are you sure you want to delete this message?")){
        /* Update message_id value of form */
        $('#delete_message input[name="message_id"]').val($(this).data("message_id"));

        $.post($("#delete_message").attr("action"), $("#delete_message").serialize(), function(response_data){
            if(response_data.status){
                alert("Message deleted");
                $(`#message_${response_data.result.message_id}`).remove();
            }
            else{
                alert(response_data.error);
            }
        });

        return false
    }
}

function submitCreateCommentForm(){
    const create_comment_form = $("#create_comment");
    const message_id          = $(this).data("message_id");

    /* Update message_id value of form */
    $('#create_comment input[name="message_id"').val(message_id);
    $('#create_comment input[name="content"]').val($(`#message_${message_id}_comment_content`).val());

    $.post(create_comment_form.attr("action"), create_comment_form.serialize(), function(response_data){
        if(response_data.status){
            if($(`#message_${message_id}_comments .no_comments_msg`).length){
                $(`#message_${message_id}_comments`).html(response_data.result.comment_html);
            }
            else {
                $(`#message_${message_id}_comments`).append(response_data.result.comment_html);
            }
        }
        else{
            alert(response_data.error);
        }
    });

    $(".message_comment").val("");

    return false
}

function submitDeleteCommentForm(){
    if(confirm("Are you sure you want to delete this comment?")){
        /* Update comment value of form */
        $('#delete_comment input[name="comment_id"]').val($(this).data("comment_id"));

        $.post($("#delete_comment").attr("action"), $("#delete_comment").serialize(), function(response_data){
            if(response_data.status){
                alert("Comment deleted");
                $(`#comment_${response_data.result.comment_id}`).remove();
            }
            else{
                alert(response_data.error);
            }
        });

        return false
    }
}