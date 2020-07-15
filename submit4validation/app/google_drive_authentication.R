
# for the app to work _from the server_, you need to upload a token that allows the this app to access your google sheet
# this file can be created with the following code:

#' 1. make sure your working directory is the rcm_apps repository root folder (you an check this is the case with `getwd()`)
#' 2. in the following steps, best to NOT use your personal gmail account. Use a throwaway account.
#' 3. run the two lines of code below
#' 4. follow the instructions in the console/browser; a browser window should open asking you to log into your google account, with a code to copy paste into the console etc.
#' 5. Once it's done, there should be a new file created in "./submit4validation/app/" called "shiny_app_token.rds"
#' 6. now you can deploy the app; make sure to include that file (keep/add the tick on that file in the popup when publishing the app)
#' 8. Now DELETE the .rds file.
#' 9. IMPORTANT: DO NOT PUSH THE shiny_app_token.rds FILE TO GITHUB or share it with anyone. It contains sensitive google authentification info!



shiny_token <- gs4_auth() # authenticate w/ your desired Google identity here
saveRDS(shiny_token, "./submit4validation/app/shiny_app_token.rds")
