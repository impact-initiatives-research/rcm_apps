
# for the app to work _from the server_, you need to upload a token that allows the this app to access your google sheet
# this file can be created with the following code:

## prepare the OAuth token and set up the target sheet:
##  - do this interactively
##  - do this EXACTLY ONCE

shiny_token <- gs_auth() # authenticate w/ your desired Google identity here
saveRDS(shiny_token, "./submit4validation/app/shiny_app_token.rds")
