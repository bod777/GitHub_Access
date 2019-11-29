#install.packages
#install.packages("jsonlite")
library(jsonlite)
#install.packages("httpuv")
library(httpuv)
#install.packages("httr")
library(httr)



oauth_endpoints("github")

myapp = oauth_app(appname = "Bríd_O'Donnell_TCD",
                  key = "527245096804e1de06ee",
                  secret = "d878f37b6ce9b3d5e5008975ab71b4954df3b667")

# Get OAuth credentials
github_token = oauth2.0_token(oauth_endpoints("github"), myapp)

# Use API
gtoken = config(token = github_token)
req <- GET("https://api.github.com/users/bod777/repos", gtoken)

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

#install.packages("plotly")
library(plotly)

# Interrogate the Github API to extract data from my github account

myData = fromJSON("https://api.github.com/users/bod777")
myData$followers #displays number of followers
myData$following #Number of people i am following
myData$public_repos #Number of repositories I have
myData$bio #Shows my bio

followers = fromJSON("https://api.github.com/users/bod777/followers")
followers$login #Names of my followers
followers$type
followers$followers_url

following = fromJSON("https://api.github.com/users/bod777/following")
following$login #shows the names of all the people i am following 
following$type
following$following_url

repos = fromJSON("https://api.github.com/users/bod777/repos")
repos$full_name #Names of my repositories 
repos$created_at #When repositories were created
repos$language #language of my repos

#Convert dataframe to JSON
myDataJSon = toJSON(myData, pretty = TRUE)
myDataJSon

#Interrogating another user 'paulirish' and put their data into a data.frame

userData=GET("http://api.github.com/users/paulirish/followers?per_page=100;", gtoken)
stop_for_status(userData)
extract = content(userData)
githubDB=jsonlite::fromJSON(jsonlite::toJSON(extract))

#subset dataframe
githubDB$login
#retrieve a list of usernames
id=githubDB$login
user_ids=c(id)

users=c() #empty vector
usersDB=data.frame( #empty data.frame
  username=integer(),
  following=integer(),
  followers=integer(),
  repos=integer(),
  dateCreated=integer()
)

for(i in 1:length(user_ids))
{
  #Retrieve a list of individual users 
  followingURL = paste("https://api.github.com/users/", user_ids[i], "/following", sep = "")
  followingRequest = GET(followingURL, gtoken)
  followingContent = content(followingRequest)
  
  #Ignore if they have no followers
  if(length(followingContent) == 0)
  {
    next
  }
  
  followingDF = jsonlite::fromJSON(jsonlite::toJSON(followingContent))
  followingLogin = followingDF$login
  
  #Loop through 'following' users
  for (j in 1:length(followingLogin))
  {
    #Check that the user is not already in the list of users
    if (is.element(followingLogin[j], users) == FALSE)
    {
      #Add user to list of users
      users[length(users) + 1] = followingLogin[j]
      
      #Retrieve data on each user
      followingUrl2 = paste("https://api.github.com/users/", followingLogin[j], sep = "")
      following2 = GET(followingUrl2, gtoken)
      followingContent2 = content(following2)
      followingDF2 = jsonlite::fromJSON(jsonlite::toJSON(followingContent2))
      
      #Retrieve each users following
      followingNumber = followingDF2$following
      
      #Retrieve each users followers
      followersNumber = followingDF2$followers
      
      #Retrieve each users number of repositories
      reposNumber = followingDF2$public_repos
      
      #Retrieve year which each user joined Github
      yearCreated = substr(followingDF2$created_at, start = 1, stop = 4)
      
      #Add users data to a new row in dataframe
      usersDB[nrow(usersDB) + 1, ] = c(followingLogin[j], followingNumber, followersNumber, reposNumber, yearCreated)
      
    }
    next
  }
  #Stop when there are more than 400 users
  if(length(users) > 400)
  {
    break
  }
  next
}

#Link R to plotly. This creates online interactive graphs based on the d3js library
Sys.setenv("plotly_username"="odonneb4")
Sys.setenv("plotly_api_key"="Ty4mQC65CQB6XYJbW3T1")

plot1 = plot_ly(data = usersDB, x = ~repos, y = ~followers, 
                        text = ~paste("Followers: ", followers, "<br>Repositories: ", 
                                      repos
                        ), color=~dateCreated)
plot1
api_create(plot1, filename = "Scatter Graph: Repositories vs Followers")
#Link: https://plot.ly/~odonneb4/11/#/

#Link R to plotly. This creates online interactive graphs based on the d3js library
Sys.setenv("plotly_username"="odonneb4")
Sys.setenv("plotly_api_key"="Ty4mQC65CQB6XYJbW3T1")

plot2 = plot_ly(data = usersDB, x = ~following, y = ~followers, color = ~dateCreated, text = ~paste("Followers: ", followers, "<br>Repositories: ", repos, "<br>Date Created:", dateCreated))
plot2
api_create(plot2, filename = "Scatter Graph: Following vs Followers")

#Link: https://plot.ly/~odonneb4/13/#/