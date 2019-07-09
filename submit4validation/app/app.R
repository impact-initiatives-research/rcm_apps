#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(ggplot2)
source("./components.R")

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

   # Application title
   title=("Submit for Validation"),
   #    header=mainPanel(selectInput("unit", "Unit:",
   #             c( "all" = "all",
   #                "research design" = "research design",
   #               "data" = "data",
   #               "reporting" = "reporting",
   #               "GIS"="GIS",
   #               "other"="other"
   #              ),selected = "all"))
   # ,
   h2('Data Unit Validation Submission'),
   conditionalPanel('output.displayinput!="visible" & output.submission_success != "yes"',"Loading..."),
   conditionalPanel('output.displayinput=="visible"',
   shiny::textInput("email",label = "your email:",value = "",width="100%"),
   h3('Identify the item to be submitted from our list of expected submissions:'),
   htmlwarning("Please use the form below to select the item you want to submit from the list of items that are expected based on submitted ToRs."),
      selectInput("country", "Country", c( "loading..."= "loading"),selected = "loading...",width = "100%"),
      selectInput("rcid", "research cycle",c( "select country first"= "loading"),selected = "select country first",width = "100%"),
      htmlnote("The 'item ID' is a unique identifier that allows us to match this submission with the correct item in our tracking system. Each expected item has a preassigned ID (there may be only one for your research cycle/round)"),
      conditionalPanel(condition="input.idnotfound== false",
                       selectInput("file.id",
                                   "item ID",
                                   c( "select country first"= "loading"),
                                   selected = "select research cycle id first",
                                   width = "50%",multiple=T)),
   conditionalPanel(
     condition = "input.idnotfound == true",
     shiny::textInput("newid",
                      "give a new name to your item. It should be of the format [research cycle id]_[research cycle name]_[round/month]_[data and/or analysis]_[filenumber]",
                      width="50%")
   ) ,
   checkboxInput("idnotfound","I can not find an item ID matching my submission",value = FALSE,width="50%"),
   conditionalPanel(
     condition = "input.idnotfound == true",
     htmlwarning("Please make 100% sure that no existing item ID matches your submission before ticking the above.")
     
     ),
      selectInput("round", "Round",c( "select file ID first"= "loading"),selected = "select file ID first",width = "100%"),
   h3('Add basic information:'),
   shiny::dateInput("deadline",label = "external deadline for this validation:",min = Sys.Date()+3),
      checkboxInput("complete", "with this submission, we have submitted all data/analysis for this research cycle (for this round)", value = FALSE, width = "100%"),
      shiny::textAreaInput("comment",label = "Comment / additional information:",value = "",width = "100%"),
      selectInput("datatype", "Type(s) of data submitted",c( "Household Interviews"= "hh","Key Informants"="ki","Qualitative Data (e.g. FGDs)"="fgd"),multiple=T),
      checkboxInput("emergency", "This is an exceptional emergency and I need this validated immediately", value = FALSE, width = "100%"),
      htmlnote("you may need to log into a google Account for authentification. This can be any google account."),
      shiny::uiOutput("not_complete_message"),
      shiny::actionButton(inputId = "send", label = 'submit for validation',style="background-color:#FF0000;color:#FFFFFF")
   ),
   submission_done_panel(),
   HTML((("<br><br>"))))



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

  # devtools::install_github("mabafaba/researchcyclematrix")
  require("researchcyclematrix")
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
    complete <- complete_file.id & complete_email
    if(!complete){
      message<-HTML(paste("ERROR:",ifelse(complete_file.id,"","A country, research cycle and item ID must be selected before submission."),
                              ifelse(complete_email,"","A valid email address must be selected before submission."),sep="<br>"))
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
    api_request_return <- researchcyclematrix:::g_sheets_append_row(c(
          fill0length(today_standardised_format),
          fill0length(today),
          fill0length(input_filled$country),
          fill0length(input_filled$rcid),
          fill0length(input_filled$idnotfound),
          fill0length(fileid),
          fill0length(input_filled$newid),
          fill0length(input_filled$round),
          fill0length(input_filled$email),
          fill0length(input_filled$comment),
          fill0length( format.Date(input_filled$deadline,format="%d-%b-%y")),
          fill0length(input_filled$complete),
          fill0length( paste(input_filled$datatype,collapse=" & ")),
          fill0length(input_filled$emergency)
                                                )
                                                )

    print(api_request_return)

    
    if(input$idnotfound){
      fileid<-paste("[[new item id]] ",input$newid)
    }
    
    to="martin.barner@impact-initiatives.org;eliora.henzler@impact-initiatives.org;sharon.orengo@impact-initiatives.org;chiara.debenedetti@impact-initiatives.org"
    cc="katya.ivanova@impact-initiatives.org;lea.barbezat@impact-initiatives.org;nayana.das@impact-initiatives.org;renaud.zambeaux@impact-initiatives.org"
    subject<-paste0(input$rcid,": ","for data unit validation - ",fileid)
    body<-(paste0(
"Dearest Data Unit,\n\nPlease find attached for validation the files relating to:\n\n",
input$rcid,"\n",
fileid,"\n\n",
"We would ideally like this to be validated before ",input$deadline,"\n\n\n",
"further comments on the files:\n\n",

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
    
    browseURL(mail_href)

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