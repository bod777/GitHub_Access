#install.packages
library(jsonlite)
library(httpuv)
library(httr)

oauth_endpoints("github")

myapp = oauth_app(appname = "Bríd_O'Donnell_TCD",
                  key = "527245096804e1de06ee",
                  secret = "d878f37b6ce9b3d5e5008975ab71b4954df3b667")

# Get OAuth credentials
github_token = oauth2.0_token(oauth_endpoints("github"), myapp)

1

# Use API
gtoken = config(token = github_token)
req <- GET("https://api.github.com/users/jtleek/repos", gtoken)

# Take action on http error
stop_for_status(req)

# Extract content from a request
json1 = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# Subset data.frame
gitDF[gitDF$full_name == "bod777/datasharing", "created_at"] 


# The code above was sourced from Michael Galarnyk's blog, found at:
# https://towardsdatascience.com/accessing-data-from-github-api-using-r-3633fb62cb08


# Interrogate the Github API to extract data from my github account

myData = fromJSON("https://api.github.com/users/bod777")

#displays number of followers
myData$followers
followers = fromJSON("https://api.github.com/users/bod777/followers")
followers$login #Names of my followers

myData$following #Number of people i am following

following = fromJSON("https://api.github.com/users/bod777/following")
following$login #shows the names of all the people i am following 

myData$public_repos #Number of repositories I have


repos = fromJSON("https://api.github.com/users/bod777/repos")
repos$full_name #Names of my repositories 
repos$created_at #When repositories were created

myData$bio #Shows my bio
