# Diversity in Data Feb 2021
inventions <- read.csv('source_data/Inventions and Scientific Achievements.csv',stringsAsFactors = F)
achievements <- read.csv('source_data/Notable Black Achievements dataset.csv',stringsAsFactors = F)

#install.packages("WikipediR")
library(WikipediR)
library(dplyr)
library(rvest)
library(stringr)
library(httr)

inventions$order <- 1:nrow(inventions) 

#https://en.wikipedia.org/wiki/List_of_African-American_inventors_and_scientists

# return wikipedia image 
inventions$page <- inventions$links_corrected
inventions$page <- gsub('https://en.wikipedia.org/wiki/','',inventions$page)
inventions$page <- gsub('_',' ',inventions$page)
#test <- page_content("en","wikipedia", page_name = urls[1], as_wikitext=TRUE)
#page_metadata <- page_info("en","wikipedia", page =  urls[1])

for(i in 1:length(inventions$page)){
  page_metadata <- page_info("en","wikipedia", page =inventions$page[i])
  length <- page_metadata$query$pages[[1]]$length
  
  if(inventions$page[i] == gsub('_',' ','List_of_African-American_inventors_and_scientists')){
    print("no wikipedi page")
    length <- 0
  }
  
  if(i == 1){
    output <- length
  }
  if(i > 1){
    output <- c(output,length)
  }
}

african_american_invents <- output

all_inventors <- 'https://en.wikipedia.org/wiki/List_of_inventors'
ai_html <- read_html(all_inventors)

inventors <- html_nodes(ai_html,"ul li") %>% as.character()

page <- str_extract(inventors,'\\/wiki\\/[\\w|%|_|\\-|\\.]+')
name <- str_extract(inventors,'title=\\\"[a-zA-Z|_|\\-|\\.|\\s]+')
age_range <- str_extract(inventors,'\\(.*\\)')
birth <- substr(age_range,1,5)

df <- data.frame(wiki_links=page,birth_year=birth,stringsAsFactors = F)
df <- filter(df,!is.na(wiki_links))

df <- df[1:989,]

df$page <- gsub("/wiki/",'',df$wiki_links)
df$page <- gsub('_',' ',df$page)

for(i in 1:length(df$page)){
  page_metadata <- page_info("en","wikipedia", page =df$page[i])
  length <- page_metadata$query$pages[[1]]$length
  if(i == 1){
    output <- length
  }
  if(i > 1){
    output <- c(output,length)
  }
  print(i)
}

all_inventors <- output

mean(african_american_invents)
mean(all_inventors)




image_df <- data.frame(url=NA,image=NA,stringsAsFactors = F)

for(i in 1:length(urls)){
#for(i in 1:3){ 
  status <- http_status(GET(urls[i]))$category
  
  if(status!="Success"){
    a <- ''
  }

  if(status=="Success"){
    wiki <- read_html(urls[i])
    links <- wiki %>%
      html_nodes(".thumbinner a img") %>%
      html_attr("src") %>%
      as.data.frame()
    
    a <- ifelse(is.na(links[1,1]),'',as.character(links[1,1]))
  }
  
  df <- data.frame(url=urls[i],image=a,stringsAsFactors = F)
  image_df <- rbind(image_df,df)
  
}

image_df <- image_df %>% filter(!is.na(image))
image_df <- unique(image_df)

invention_df <- inventions %>% left_join(image_df, by = c("links" = "url"))
write.csv(invention_df,"transformed_data/output_inventors.csv",row.names = F)

### Download Images from URLs

all_images <- filter(image_df,image!='')$image[1:3]
all_images <- substr(all_images,3,nchar(all_images))

for(i in 1:length(all_images)){
  a <- all_images[i]
  download.file(a,paste0('downloaded_images/',i,'.jpg'), mode = 'wb')
}

