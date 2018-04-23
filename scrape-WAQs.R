library(rvest)
library(stringr)
library(dplyr)
library(curl)

# Create initial dataframe
df1 <- readRDS("Data/WQ.RDS")

# WAQ From June 2016 to November 2017 have URLs between 1 and 3386 - not necessarily in the correct order
# Whereas in November 2017 (at WAQ 75000) have URLs matching their WAQ number
min <- max(df1$number)

# Not an elegant solution to find the latest Question number, but an easy way to go without requiring any buttons to be clicked
# Only 8 displayed from initial search, so will often miss a handful of results, these will likely be unanswered though
wqn <- read_html("http://record.assembly.wales/Search/?type=7")
waqn <- html_nodes(wqn, ".title")
max <- as.integer(max(str_replace(html_text(waqn), "Written Question - WAQ", "")))


for(i in min:max){
  #Creates URL matching 
  wq <- read_html(paste0("http://record.assembly.wales/WrittenQuestion/",i))
  
  name <- html_nodes(wq, ".name")
  title <- html_nodes(wq, ".title")
  withdraw <- html_nodes(wq, ".withdrawn")
  date <- html_nodes(wq, ".date")
  text <- html_nodes(wq, "p")
  welsh <- html_nodes(wq, ".welsh")
  
  
  amname <- str_trim(html_text(name))
  wqtitle <- str_trim(html_text(title[1]))
  withdrawn <- !identical(html_text(withdraw),character(0))
  
  if(length(title)>1){
    answeredby <- str_replace(str_trim(html_text(title[2])), "Answered by ","")
  } else {
    answeredby <- NA
  }
  
  if(length(date)>1){
    answered <-  as.Date(str_replace(str_trim(html_text(date[2])),"Answered on ",""), format="%d/%m/%Y")
  } else {
    answered <- NA
  }
  
  tabled <- as.Date(str_replace(str_trim(html_text(date[1])),"Tabled on ",""), format="%d/%m/%Y")
  
  qtext <- str_trim(html_text(text[1]))
  if(length(text)>1){
    atext <- str_trim(html_text(text[2]))
  } else {
    atext <- NA
  }
  
  welshyn <- !identical(html_text(welsh),character(0))
  
  df2 <- data_frame("question_no" = wqtitle, "name" = amname, "tabled_dt" = tabled,
                    "response_name" = answeredby, "response_dt" = answered, "question" = qtext,
                    "answer" = atext, "welsh" = welshyn, "withdrawn" = withdrawn, "number" = i)
  
  df1 <- bind_rows(df1, df2)
}

# For the time being, best to manually remove questions after the point at which multiple "Yet to be answered" responses slip in
# Will at a later date add functionality that also removes and re-queries any WAQ where answer is ~ "To be answered by"

df1 <- subset(df1,number < 76294)

#Save output
saveRDS(df1,"Data/WQ.RDS")
write.csv(df1, "Data/WQ.csv")
