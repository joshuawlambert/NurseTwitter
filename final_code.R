library(twitteR)
library(rtweet)
library(xlsx)

tokens<-c("Nurs"," RN "," NP "," BSN "," MSN "," DNP "," CNS "," CRNA "," CNE "," CNL "," CNO "," CNA "," CNM ",
  " LPN "," LVN "," NA "," ASN "," ADN ")
tokens<-tolower(tokens)
toks<-paste(tokens,collapse = "|")

#there are 36 files
#take each file, extract tweet_ids, use twitter to look those up (in batches of 80,000)
#There are 10,000,000 tweets in each file. At 80K per round, that is 125 batches for each file.
#at 20 min each that is 125x20/60 which is 41 hrs per file or 62 days
#identify tweeter's descriptions which contain atleast one above token (lower-case)
#wait 15 min between batches
for(j in 31){
  show(paste("on file",j))
  coronavirus_tweets<-NULL
  covid<-NULL
  ##Read in Data
  path<-paste("~/Twitter data_02_08/coronavirus-through-03-December-2020-",sprintf("%02d", j-1),".txt",sep = "")
  coronavirus_tweets <-read.table(path)
  covid<-coronavirus_tweets[,1]
  
  #extract tweets which contain at least 1 of the tokens listed above.
  #descriptions and tokens are lower-cased
  full<-NULL
  for(i in 1:125){
    show(i)
      tmp<-lookup_tweets(covid[1:80000])
      full<-rbind(full,tmp[which(grepl(toks,tolower(tmp$description))),])
      covid<-covid[-c(1:80000)]
  }
  
  #save file when completed
  df <- apply(full,2,as.character)
  write.csv(file = paste("pulled_data/file_",sprintf("%02d", j),".csv",sep = ""),x=df)
  
  #sleep so twitter doesn't get mad
  show("done. pausing for 15min")
  Sys.sleep(60*15)
}