library(rtweet)
library(tidyverse)
library(lubridate)
library(ggrepel)


appname <- ""
# api key (replace the following sample with your key)
key <- ""
# api secret (replace the following with your secret)
secret <- ""

twitter_token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret)


# Select Twitter usernames for accounts belonging to AMs from list maintained by myself 
# (NAW Official Twitter List lacking Jack Sargeant at time of writing)
WelshAMs <- lists_members(slug = "welshams", owner_user = "jack_govier", n = 5000,
                          cursor = "-1", token = twitter_token)

WelshAMs$timestamp <- as.POSIXct(Sys.time())
WelshAMs$xuser_id <- paste0("x",WelshAMs$user_id)

View(WelshAMs)
WelshAMs <- WelshAMs[,c(1:5,8:12,17,26,41:42)]

dt <- as.Date(WelshAMs[[1,13]]+3600)

write.csv(WelshAMs, paste0("Data/Users-",dt,".csv"))

data <- list.files("data", full.names = TRUE)
  data <- data[1:(length(data)-2)]

user_data <- map(data, read.csv)

user_data <- bind_rows(user_data)[-1]

View(user_data)


ud1 <- subset(user_data, timestamp == "2018-04-08 04:08:00"|timestamp == "2018-05-27 04:03:24")
View(ud1)

ud1 <- ud1[,c("name","followers_count")]
  

install.packages("sqldf")
library(sqldf)

ud1 <- sqldf("with min as (select xuser_id, followers_count from user_data where timestamp = \"2018-04-21 19:17:00\"),
       max as (select xuser_id, followers_count from user_data where timestamp = \"2018-05-27 04:03:24\")
      
select min.xuser_id, min.followers_count as f1, max.followers_count as f2 
from min
inner join max on min.xuser_id = max.xuser_id
group by min.xuser_id
      ")

ud2 <- inner_join(ud1, AMs)
View(ud2)
ud2$diff <- ud2$f2-ud2$f1
ud2$percdiff <- ud2$diff/ud2$f1
View(ud2)
