
greybox<-function(...){
  div(...,style="background-color:#DDDDDD;padding:10px;font-size:1em;")
}

htmlnote<-function(text){
  shiny::div(shiny::br(),
      text,
      shiny::br(),shiny::br(),style="color:orange;font-size:0.9em;")
}
htmllink_deletionform<-function(){
  shiny::div(HTML(paste("<br> <a href='https://drive.google.com/file/d/11zcwtZ-gb9kyLQCb3dbesxoUc5B-Jcvp/view?usp=sharing' target=\"_blank\">Please complete the deletion form attached to this link. </a> <br>")),
style="color:red;font-size:1em;")
}

htmlwarning_bold<-function(text){
  
    shiny::div(shiny::br(),
               text,
               shiny::br(),shiny::br(),style="color:#FF0000;font-size:1em;font-weight:bold;")
}
htmlwarning<-function(text){
  shiny::div(shiny::br(),
      text,
      shiny::br(),shiny::br(),style="color:#FF0000;font-size:1em;")
}

submission_done_panel<-function(...){
  conditionalPanel(condition='output.submission_success == "yes"',

   shiny::div(
     HTML("<b>Almost done!</b><br><br>"),
     HTML("Next steps: <br><br>"),
     HTML("<ol>
            <li>Send the email draft below along with the files that need to be validated to the data unit and the deletion form. Use the exact email header,recipients, cc and email body draft below. You can copy & paste them, or open a draft email with everything filled in for you:</li>"),
     shiny::div(uiOutput(outputId = "submission_email_link"),"(this will open the email program installed on your computer (i.e. Microsoft Outlook), so the link will only work if you have set up outlook or similar with your email address on the computer you are working on.)"),
    HTML("<li>After completing step 1, the validation submission process is <b>complete</b>. you can then close this window, or click the link on the bottom of this page to make another submission.</li>
          </ol>"),
     shiny::div("Thank you very much.
                You filling this form helps us keep track of everything, and make sure we validate your products in time."
                ),
   br(),br(),
   shiny::div(HTML(paste("<b>Email Subject (copy & paste exactly):</b>",
                  greybox(uiOutput("submission_email_subject"))))),
   shiny::div(HTML(paste("<br><br><b>To:</b>",
                  greybox(uiOutput("submission_email_to"))))),
   shiny::div(HTML(paste("<br><br><b>CC:</b>",
                         greybox(uiOutput("submission_email_cc"))))),
   shiny::div(HTML(paste("<br><br><b>Draft:</b><br><br>",
                  greybox(uiOutput("submission_email_body_html"))))),
   br(),br(),HTML("you can close this window, or"),
   actionLink("submit_another_one","go back to make another submission.")
   )
  )

}
