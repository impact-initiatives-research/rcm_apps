
# for the app to work _from the server_, you need to upload an .httr-auth file.
# this file can be created with the following code:

library(googlesheets)
options(httr_oob_default=TRUE) 
gs_auth(new_user = TRUE) 

