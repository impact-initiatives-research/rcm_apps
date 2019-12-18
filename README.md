
# IMPACT HQ research department shiny apps for the Research Cycle Matrix

This repository contains two shiny apps for the research department's management of the research cycle matrix:
- rcmviewer: a dashboard to view the research cycle matrix
- submit4validation: the validation submission form



# How to deploy these shiny apps


## Set up Shiny and shinyapps.io access locally
follow the first part of the [instructions for deploying shiny apps](https://shiny.rstudio.com/articles/shinyapps.html). The sections you need to complete are:

- How to install rsconnect
- Create a shinyapps.io account
- Configure rsconnect

## Clone the rcm_apps repository

in your windows shell / os x terminal, run: 

```
git clone https://github.com/mabafaba/rcm_apps
```


## Test the app locally

enter the folder of the shiny app you want to run and open `app.R` in RStudio. Then run:

```
	library(shiny)
	runApp()
```

This will run the app on your local computer but the app will not yet be public to anyone.

If it fails due to missing packages, install them (only from remote sources such as CRAN or GitHub, not from a local source!) 


**If your app works locally, this does not necessarily mean that it will also work when you try to publish it on a server.** Typical reasons could be:

- inaccessible packages, for example if you have installed a package from a local source rather than the github repository
- access / authentification issues (i.e. google drive which is relevant for the submit4validation app)


## Set up google drive authentification (for submit4validation app)

This part only needs to be done for the submit4validation app, or other apps that need to edit sheets on google drive.

For the app to work _from the server_, you need to upload a token that allows the this app to access your google sheet
this file can be created with the following code:

1. make sure your working directory is the rcm_apps repository root folder (you an check this is the case with `getwd()`)
2. in the following steps, best to NOT use your personal gmail account. Use a throwaway account!
3. run these two lines of code:
```
shiny_token <- gs_auth() # authenticate w/ your desired Google identity here
saveRDS(shiny_token, "./submit4validation/app/shiny_app_token.rds")
```
4. follow the instructions in the console/browser; a browser window should open asking you to log into your google account, with a code to copy paste into the console etc. Again: It's best to use a throwaway google account for this. In theory this should be safe but you do not want a file with personal access tokens for your private account flying around. 
5. Once it's done, there should be a new file created in "./submit4validation/app/" called "shiny_app_token.rds"
6. now you can deploy the app; make sure to include the "shiny_app_token.rds" file (keep/add the tick on that file in the popup when publishing the app). Either by following the instructions in the next step or by hitting the blue "publish" button in the top right corner of the RStudio script panel when the app is open.
8. **Now DELETE the .rds file. DO NOT PUSH THE shiny_app_token.rds FILE TO GITHUB or share it with anyone. It contains sensitive google authentification info!**


## Publishing apps to shinyapps.io

If you have followed the first parts of the [instructions for deploying shiny apps](https://shiny.rstudio.com/articles/shinyapps.html) as noted above, you should be able to publish the app directly by opening `app.R` in RStudio, then running:

```
rconnect::deployApp()
```

Alternatively, you can hit the blue "publish" button that appears in the top right corner of the RStudio script panel when you have an shiny `app.R` file open.
 
## Test the remote app

Especially the `submit4validation` app may run ok but not behave as it should. You should make a few different submissions and see if it works / if the submissions actually end up in the relevant google sheet. (you can open the google sheet in the browser with `researchcyclematrix::subs_browse()`)

## Debugging remote shiny apps

If your app works locally but fails on the server, you can see the R console log of the application as it runs/ran on the server. To do this you need to:

1. [log into your shinyapps.io account](https://www.shinyapps.io/admin/#/login?redirect=%2Fdashboard) in your browser
2. click on "Applications", find your app and open it's console log.

## Note on shinyapps.io passwords

Shinyapps.io doesn't have an automated "forgot my password" system. If you don't have the password anymore you'll have to email them and wait for someone to manually give you access again.

## Resources

[shinyapps.io documentation](https://docs.rstudio.com/shinyapps.io/)