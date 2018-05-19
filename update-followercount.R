library(rtweet)
library(tidyverse)
library(lubridate)
library(ggrepel)


appname <- "CBBSentiment"
# api key (replace the following sample with your key)
key <- "AeU8ZvDs6kIBq3gWOVakD9rGJ"
# api secret (replace the following with your secret)
secret <- "2MjblAqkMLB02zIuMll1MnSwgfjh78CPehOzI7U8TOFHpZqDfX"

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
