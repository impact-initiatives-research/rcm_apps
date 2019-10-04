
# for the app to work _from the server_, you need to upload an .httr-auth file.
# this file can be created with the following code:

# library(googlesheets)
# options(httr_oob_default=TRUE) 
# gs_auth(new_user = TRUE) 



## prepare the OAuth token and set up the target sheet:
##  - do this interactively
##  - do this EXACTLY ONCE

# 
# shiny_token <- gs_auth() # authenticate w/ your desired Google identity here
# saveRDS(shiny_token, "./submit4validation/app/shiny_app_token.rds")
