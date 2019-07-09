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
# library(researchcyclematrix)
# Define UI for application that draws a histogram
ui <- fluidPage(
  navbarPage(
   # Application title
   title=("RCM"),
      header=mainPanel(selectInput("unit", "Unit:",
               c( "all" = "all",
                  "research design" = "research design",
                 "data" = "data",
                 "reporting" = "reporting",
                 "GIS"="GIS",
                 "other"="other"
                ),selected = "all"))
   ,
   tabPanel("Overview",mainPanel(plotOutput("timeline"))),
   tabPanel("Inconsistencies",


      # Show a plot of the generated distribution
      mainPanel(
        # titlePanel("Overview"),
        # dataTableOutput('issuetableoverview'),
        # titlePanel("All inconsistencies"),
        dataTableOutput('issuetable')
         #

      )),
   tabPanel("Longest with HQ",
   mainPanel(
     dataTableOutput('longestwithhq')

   )),
   tabPanel("Submission Due",
   mainPanel(
     dataTableOutput('expected')

   )),
   tabPanel("Milestone missed",
            mainPanel(
              dataTableOutput('passedmilestone')

            )),
   tabPanel("useless gant chart",
            mainPanel(
              plotOutput("distPlot",width = "100%",height=paste0(1000*5,"px"))

            )),
   tabPanel("Data Unit to-validate",
     h2("to validate next:"),
     div(dataTableOutput('data.unit.to.validate'),style="font-size:80%;"),
     h2("submissions with new ID, or id could not be found:"),
     div(dataTableOutput('data.unit.to.validate.not.found.in.rcm'),style="font-size:80%;")
   )
   ))


# Define server logic required to draw a histogram
server <- function(input, output,session) {
  library("knitr")
  library("dplyr")
  library("knitr")
  library("tidyr")
  library("magrittr")
  library("researchcyclematrix")
  # source("rcm_functions.R",local=T)




  rcm_all<-rcm_download(include_archived = T,include_validated = T,after_year = "2015",gdrive_links = TRUE)

  

  rcm_unit_subset<-function(rcm,unit){
    if(unit=="all"){return(rcm)}
    rcm[rcm$unit==input$unit,]
  }


  subs<-subs_download()

  rcm_rows_from_subs<-match(rcm_all$file.id,subs$file.id)
  rcm_all$submitter_comment<-subs$comment[rcm_rows_from_subs]
  rcm_all$submitter_email<-subs$email[rcm_rows_from_subs]
  rcm_all$submitter_emergency<-subs$emergency[rcm_rows_from_subs]
  rcm_all$in.country.deadline<-subs$in.country.deadline[rcm_rows_from_subs]
  rcm_all$hq_focal_point<-researchcyclematrix:::hq_focal_point(rcm_all$rcid)
  rcm_all$hq_focal_point[rcm_all$unit!="data"]<-NA

  rcm<-rcm_all[!grepl("validated",rcm_all$status),]
  rcm<- rcm_all[!grepl("validated",rcm_all$status) & !rcm_all$archived,]

  output$data.unit.to.validate<-renderDataTable(rcm[researchcyclematrix:::rcm_is_data_unit_item(rcm),] %>%
    filter(.,grepl("HQ",.$status)) %>%
    arrange(date.hqsubmission.actual) %>%
    select(hq_focal_point,file.id,
           type,
           date.hqsubmission.actual,
           in.country.deadline,
           submitter_comment,
           submitter_email))

  subs_ids_to_process_manually<-is.na(researchcyclematrix:::subs_rcm_rows(subs,rcm_all)) | as.logical(subs$file.id.new)
  subs_manual<-subs[subs_ids_to_process_manually,,drop=F]
  subs_manual<-data.frame(hq_focal_point=researchcyclematrix:::hq_focal_point(subs_manual$rcid),subs_manual)
  output$data.unit.to.validate.not.found.in.rcm<-renderDataTable(subs_manual)

  output$issuetable <- renderDataTable({rcm_check(rcm_unit_subset(rcm,input$unit))},escape = F)
  output$issuetableoverview<-renderDataTable({
    issues<-rcm_check(rcm_unit_subset(rcm[!rcm$archived,],input$unit))
    issues_overview<-table(list(issues$issue,rcm_unit(rcm[issues$id,]))) %>% as.data.frame() %>% spread("X.2",value = "Freq")
    issues_overview<-issues_overview %>% rename(`issue type`=X.1)
    issues_overview
    },escape = F)
  output$longestwithhq<-renderDataTable({

    subs<-rcm_unit_subset(rcm,input$unit)
    subs<-researchcyclematrix:::rcm_add_validation_button(subs)
    subs<-researchcyclematrix:::rcm_longest_with_hq(subs,n=50,add.columns = "change.state")
      subs
    },escape = F)
  output$expected<-renderDataTable({researchcyclematrix:::rcm_submission_expected(rcm_unit_subset(rcm,input$unit))},escape = F)
  output$passedmilestone<-renderDataTable({
    rcm[which(researchcyclematrix:::rcm_passed_milestone(rcm) & !rcm$archived & !grepl("validated",rcm$status)),c("link","rcid","date.milestone","status")]
      },escape=F
    )
  output$distPlot <- renderPlot({

     # draw the histogram with the specified number of bins
     researchcyclematrix:::rcm_gant(rcm_unit_subset(rcm,input$unit))
  },height = 10000)

  output$timeline<-renderPlot({researchcyclematrix:::validation_timeline(rcm_all,60,30)},height = 300)


  observeEvent(input$file_id_validated, {
    rcm_set_to_validated(gsub("^valbutton_","",input$file_id_validated))
    # print(input$file_id_validated)
  })

  }

# Run the application
shinyApp(ui = ui, server = server)

