#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# MUST DO BEFORE DEPLOYING THIS APP TO THE WEB ---------------------------------------
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#' 
#' 1. on your local computer, open google_drive_authentification.R 
#' 2. in the following steps, best to NOT use your personal gmail account. Use a throwaway account.
#' 3. run the two lines of code; 
#' 4. follow the instructions; a browser window should open asking you to log into your google account, with a code to copy paste into the console etc.
#' 5. Once it's done, there should be a new file created in "./submit4validation/app/" called "shiny_app_token.rds"
#' 6. now you can deploy the app; make sure to include that file (keep/add the tick on that file in the popup when publishing the app)
#' 8. Now DELETE the .rds file.
#' 9. IMPORTANT: DO NOT PUSH THE shiny_app_token.rds FILE TO GITHUB or share it with anyone. It contains sensitive google authentification info!


library(shiny)
library(ggplot2)
source("./components.R")


googlesheets4::gs4_deauth()
#googlesheets4::gs4_auth(email = "debened...5@gmail.com", use_oob = TRUE, token = readRDS("./shiny_app_token.rds"))
# googlesheets 4::gs4_auth(token = "./shiny_app_token.rds")
  

fill0length<-function(x){
ifelse(length(x)==0,"",x)  
}

list_items_nulls_to_empty_string<-function(l,itemnames){
  l_filled<-list()
  for(itemname in names(l)){
    l_filled[[itemname]]<-l[[itemname]]
  }
  for(itemname in itemnames){
    if(is.null(l[[itemname]])){l_filled[[itemname]]<-""}else{
      l_filled[[itemname]]<-l[[itemname]]
    }
  }
  
  
  return(l)
}
# Define UI for application that draws a histogram
ui <- fluidPage(
   title=("Submit for Validation"),
   #    header=mainPanel(selectInput("unit", "Unit:",
   #             c( "all" = "all",
   #                "research design" = "research design",
   #               "data" = "data",
   #               "reporting" = "reporting",
   #               "GIS"="GIS",
   #               "other"="other"
   #              ),selected = "all"))
   # 
   
   # shiny::div(shiny::br(),
              # "OUT OF SERVICE: Unfortunately the submission form is currently not working. Please send your submission directly via email to martin.barner@impact-initiatives.org and chiara.debenedetti@impact-initiatives.org, with research@impact-initiatives.org in CC",
              # shiny::br(),shiny::br(),style="color:#FFFFFF;font-size:4em;"),
   h2('Data and Analysis Validation Submission'),
   conditionalPanel('output.displayinput!="visible" & output.submission_success != "yes"',"Loading..."),
   conditionalPanel('output.displayinput=="visible"',
   shiny::textInput("email",label = "your email:",value = "",width="100%"),
   h3('Identify the item to be submitted from our list of expected submissions:'),
   htmlwarning("Please use the form below to select the item you want to submit from the list of items that are expected based on submitted ToRs."),
      selectInput("country", "Country", c( "loading..."= "loading"),selected = "loading...",width = "100%"),
      selectInput("rcid", "research cycle",c( "select country first"= "loading"),selected = "select country first",width = "100%"),
      htmlnote("The 'item ID' is a unique identifier that allows us to match this submission with the correct item in our tracking system. Each expected item has a preassigned ID, please get in touch if you are not sure!"),
      conditionalPanel(condition="input.idnotfound== false",
                       selectInput("file.id",
                                   "item ID",
                                   c( "select country first"= "loading"),
                                   selected = "select research cycle id first",
                                   width = "50%",multiple=T)),
   conditionalPanel(
     condition = "input.idnotfound == true",
     shiny::textInput("newid",
                      "Give a new name to your item, if not present in our list. Please use the format [research cycle id]_[research cycle name]_[round/month]_[data and/or analysis]_[filenumber]",
                      width="50%")
   ) ,
   checkboxInput("idnotfound","I can not find an item ID matching my submission",value = FALSE,width="50%"),
   conditionalPanel(
     condition = "input.idnotfound == true",
     htmlwarning("Please make sure that no existing item ID matches your submission before ticking the above.")

     ),
      selectInput("round", "Round",c( "select file ID first"= "loading"),selected = "select file ID first",width = "100%"),
   h3('Add basic information:'),
      shiny::dateInput("deadline",label = "Validation deadline:",min = Sys.Date()+3),
      checkboxInput("emergency", "This is a hard deadline", value = FALSE, width = "100%"),
      checkboxInput("complete", "With this submission, we have submitted all data/analysis for this research cycle (for this round)", value = FALSE, width = "100%"),
      shiny::textAreaInput("comment",label = "Comment / additional information:",value = "",width = "100%"),
      selectInput("datatype", "Type(s) of data submitted",c( "Household Interviews"= "hh","Key Informants"="ki","Qualitative Data (e.g. FGDs)"="fgd", "Analysis"="ana"),multiple=T),
     h3('For dataset submissions, double check fulfilment of the standard checklist:'),
##   htmlwarning_bold("NEW:"),
##   htmlwarning("Personally identifiable data should not be kept beyond the date of the assessment unless it is absolutely necessary (as defined TORs validated by the HQ Research Design Unit.) After the end of the assessment, the person responsible for the raw data confirms that all personally identifiable data has been deleted from all devices as specified in the TORs. A deletion report confirming deletion of sensitive information as sepcified in the ToRs  and declaring any exceptions must be submitted to the Data Unit as a requirement for data validation"),
##Chiara: change this to point to the standard checklist!
   ##   htmllink_deletionform(),
      htmllink_st_checklist(),
      checkboxInput("raw_dataset","Raw dataset",value = FALSE,width="50%"),
      checkboxInput("clean_dataset","Clean dataset",value = FALSE,width="50%"),
      checkboxInput("cleaning_log","Cleaning log",value = FALSE,width="50%"),
      checkboxInput("deletion_log","Deletion log",value = FALSE,width="50%"),
      checkboxInput("data_deletion_report","Data Deletion Report",value = FALSE,width="50%"),
      checkboxInput("sampling","Sampling verification output",value = FALSE,width="50%"),
      checkboxInput("analysis_files","Analysis files",value = FALSE,width="50%"),
      checkboxInput("analysis_outputs","Analysis outputs",value = FALSE,width="50%"),
      checkboxInput("transcripts","[For qualitative data] A few examples of the raw transcripts and/ or debrief forms used to process and analyse
qualitative data",value = FALSE,width="50%"),
      checkboxInput("no_deletion","I am attaching all the relevant documents for data validation, as per the Standard Checklist.",value = FALSE,width="50%"),

      shiny::uiOutput("not_complete_message"),
      shiny::actionButton(inputId = "send", label = 'submit for validation',style="background-color:#FF0000;color:#FFFFFF"),
      div("Note: you may need to log into a google Account for authentication. You can use any google account.")
   ),
   submission_done_panel(),
   HTML((("<br><br>")))
   )



# Define server logic required to draw a histogram
server <- function(input, output,session) {
  output$rcm_loaded=reactive({0})
  outputOptions(output, "rcm_loaded", suspendWhenHidden = FALSE)

  library("knitr")
  library("dplyr")
  library("knitr")
  library("tidyr")
  library("magrittr")
  library("httr")
  library("researchcyclematrix")
  rcm<-rcm_download(include_archived = F,include_validated = F,after_year = "2015",raw = F,gdrive_links = F)
  rcm<-rcm[rcm$unit=="data",]
  rcm<-rcm[rcm$type!="data deletion report",]
  countrychoices<-unique(substr(rcm$rcid,1,3))
  countrychoices<-countrychoices[countrychoices!=""]

  # Update inputs

  updateSelectInput(session, "country",  choices = countrychoices)


  observeEvent(input$country, {
    rcid_choices<-c("please select.."="None",rcm$rcid[grepl(input$country,rcm$rcid)]) %>% sort
    updateSelectInput(session, "rcid",  choices = rcid_choices,selected = "None")

    # clear up lower level choices:

    updateSelectInput(session, "file.id",  choices = c("select research cycle ID first"="None"),selected = "None")
    updateSelectInput(session, "round",  choices = c("select File ID first"="None"),selected = "None")
  })

  observeEvent(input$rcid, {
    file.id_choices<-c(unique(rcm$file.id[grepl(input$rcid,rcm$rcid)]))
    file.id_choices <- file.id_choices[grepl("_DDR", file.id_choices)!= T]
    updateSelectInput(session, "file.id",  choices = file.id_choices,selected = "None")
    updateSelectInput(session, "round",  choices = c("select File ID first"="None"),selected = "None")

  })

  observeEvent(input$file.id, {
    round_choices<-c(rcm$round[grepl(input$file.id,rcm$file.id)])

    if(length(round_choices)==0){
      round_choices<-c("N/A"="None")
      }else{
        if(length(round_choices)==1 & (round_choices=="N/A" | round_choices=="")){
          round_choices<-c("N/A"="None")
    }else{
      if(length(round_choices)>1){
        round_choices<-c("please select.."="None",round_choices)
      }
    }
      }
    updateSelectInput(session, "round",  choices = round_choices)
  })

  observeEvent(input$submit_another_one, {
    output$submission_success=reactive({"no"})
    output$displayinput=reactive({"visible"})
  })


  # submission button
  observeEvent(input$send, {
    print(input$file.id)
    complete_file.id_existing<-!(all(input$file.id %in% c("loading","None","")))
    complete_file.id_new<-!(all(input$newid %in% c("loading","None","")))
    complete_file.id<-(input$idnotfound & complete_file.id_new) | (!input$idnotfound & complete_file.id_existing)
    complete_email<-(grepl(
    "^.*@.*\\..*$", # regex to recognise email address
      input$email))
    complete_deletion <- (input$no_deletion == TRUE)
    complete <- complete_file.id & complete_email & complete_deletion
    if(!complete){
      message<-HTML(paste("ERROR:",ifelse(complete_file.id,"","A country, research cycle and item ID must be selected before submission."),
                              ifelse(complete_email,"","A valid email address must be selected before submission."),
                              ifelse(complete_deletion, "", "Please make sure you have all the standard checklist items ready, and tick the box above to confirm you will attach it to the validation email"),sep="<br>"))

      output$not_complete_message<-renderUI({htmlwarning(message)})
      return(NULL)
    }else{
      output$not_complete_message<-renderUI({""})
    }
    fileid<-input$file.id
    if(length(fileid)==0){fileid<-""}
    fileid<-paste(input$file.id,collapse=" _and id_ ")

    today<-format.Date(Sys.Date(),format="%d-%b-%y")
    today_standardised_format<-as.character(Sys.time())
    input_filled<-input
    input_filled<-list_items_nulls_to_empty_string(input_filled,
                                                   c("country","rcid","idnotfound","fileid","newid","round","email","comment","deadline","complete","datatype","emergency"))
###Yann
###removing this as we are not using that sheet anymore. just keeping in the records in case we need to revert.    
    # api_request_return <- researchcyclematrix:::g_sheets_append_row(c(
    #       fill0length(today_standardised_format),
    #       fill0length(today),
    #       fill0length(input_filled$country),
    #       fill0length(input_filled$rcid),
    #       fill0length(input_filled$idnotfound),
    #       fill0length(fileid),
    #       fill0length(input_filled$newid),
    #       fill0length(input_filled$round),
    #       fill0length(input_filled$email),
    #       fill0length(input_filled$comment),
    #       fill0length( format.Date(input_filled$deadline,format="%d-%b-%y")),
    #       fill0length(input_filled$complete),
    #       fill0length( paste(input_filled$datatype,collapse=" & ")),
    #       fill0length(input_filled$emergency)
    #                                             )
    #                                             )
    # 
    # print(api_request_return)


    if(input$idnotfound){
      fileid<-paste("[[new item id]] ",input$newid)
    }

    to="megan.henery@impact-initiatives.org; oleksandra.abrosimova@impact-initiatives.org;
    louna.lonqueur@impact-initiatives.org; yann.say@impact-initiatives.org; gianluca.blaco@impact-initiatives.org"
    cc="research@impact-initiatives.org; nayana.das@impact-initiatives.org"
    subject<-paste0(input$rcid,": ","for RDD unit validation - ",fileid)
    body<-(paste0(
"Dear stellar RDD Unit,\n\nPlease find attached for validation the files relating to:\n\n",
input$rcid,"\n",
fileid,"\n\n",
"We would ideally like this to be validated before ",input$deadline,"\n\n\n",
"We are sharing with you the following:","\n",
ifelse(input$raw_dataset == TRUE, "- Raw dataset\n", ""),
ifelse(input$clean_dataset == TRUE, "- Clean dataset\n", ""),
ifelse(input$cleaning_log == TRUE, "- Cleaning log\n", ""),
ifelse(input$deletion_log == TRUE, "- Deletion log\n", ""),
ifelse(input$data_deletion_report == TRUE, "- Data Deletion Report\n", ""),
ifelse(input$sampling == TRUE, "- Sampling verification output\n", ""),
ifelse(input$analysis_files == TRUE, "- Analysis files\n", ""),
ifelse(input$analysis_outputs == TRUE, "- Analysis outputs\n", ""),
ifelse(input$transcripts == TRUE, "- A few examples of the raw transcripts and/ or debrief forms\n", ""),

"\n\n\n",
"Further comments on the files:\n\n",

input$comment,"\n\n\n",

"Thank you!"
)
)

    mail_href=URLencode(paste0('mailto:',to,'?subject=',subject,"&cc=",cc,"&body=",body))
    print(subject)
    mailtolink=paste0('<a href="',mail_href,'">Open pre-filled draft email<a>')
    output$submission_email_link<-renderUI({HTML(mailtolink)})
    output$submission_email_subject<-renderUI({HTML(subject)})
    output$submission_email_body_html<-renderUI({HTML(gsub("\n","<br>",body))})
    output$submission_email_to<-renderUI({HTML(to)})
    output$submission_email_cc<-renderUI({HTML(cc)})

    #browseURL(mail_href)

    output$submission_success=reactive({"yes"})
    output$displayinput=reactive({"hidden"})


    })

  output$displayinput=reactive({"visible"})
  output$submission_success=reactive({"no"})
  outputOptions(output, 'displayinput', suspendWhenHidden=FALSE)
  outputOptions(output, 'submission_success', suspendWhenHidden=FALSE)
  
}

# Run the application
shinyApp(ui = ui, server = server)