# Fortune 500 CEOs
# From Diverity in Data, Jan 2021
# https://data.world/diversityindata/diversityindata-january-2021

# Inspiration: https://www.instagram.com/p/CI2W7sUiPS-/

library(dplyr)

data <- read.csv('data/fortune_500_women_ceos_since_1970.csv', stringsAsFactors = F)
latest_year <- filter(data,year == '2020')

female_ceos <- latest_year$women
male_ceos <- 500 - female_ceos

ceos <- rep(1,500)
ceo_gender <- c(rep('male',male_ceos),rep('female',female_ceos))
society_gender <- c(rep('male',250),rep('female',250))

row <- rep(1:25,20)
col <- c()
for(i in 1:20){
  col <- c(col,rep(i,25))
  i <- i +1
}

fortune_500_ceos <- data.frame(gender=ceo_gender,representation=society_gender,x=row,y=col,count=ceos,stringsAsFactors = F)
fortune_500_ceos$id <- paste0(1:500,"-",fortune_500_ceos$gender)

write.csv(fortune_500_ceos,"output_fortune_500_women.csv",row.names = F)



