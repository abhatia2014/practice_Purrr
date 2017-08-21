# link https://jennybc.github.io/purrr-tutorial/bk01_base-functions.html

library(purrr)

library(githubinstall)
devtools::install_github("jennybc/repurrrsive")
library(repurrrsive)

head(got_chars[1:3])

# using map function to the list
# extracting the top three names
str(got_chars)

map(got_chars[1:3],"name")


# sapply vs purrr ---------------------------------------------------------

# use map_chr to get an atomic vector and not list

map_chr(got_chars[1:5],"culture")


# map_df to convert to data frame -----------------------------------------

map_df(got_chars[23:25],`[`,c('name','playedBy','culture'))


# however, the method may not work if data types of different types are extracted

map_df(got_chars[23:25],`[`,c('name','id'))

#alternatively, one can use the tibble feature

tibble::tibble(
  name=map_chr(got_chars[1:15],"name"),
  id=map_int(got_chars[1:15],"id")
  
  
)


# Concatenate two strings using map and dplyr ---------------------------------------

nms=got_chars[1:10] %>% 
  map_chr("name")
birth=got_chars[1:10] %>% 
  map_chr("born")


map2_chr(nms,birth,~paste(.x,"was born",.y))

# another try using tibble

df=tibble::tibble(
  nms,
  connector="was born",
  birth
)

pmap_chr(df,paste)


# Summarize function of dplyr ---------------------------------------------

library(dplyr)

library(gapminder)

(minigap=gapminder %>% 
    filter(country %in% c("Canada","Germany"),year>2000) %>% 
    droplevels()
    )

minigap %>% 
  group_by(country) %>% 
  summarise(lifeExp=mean(lifeExp))
# now taking summary of more that one variable

minigap %>% 
  group_by(country) %>% 
  summarise_at(vars(lifeExp,gdpPercap),mean)

# we'll now correlate life expectancy and year

gapminder %>% 
  group_by(country) %>% 
  summarise(cor_life_year=cor(lifeExp,year))


# Using nest function of tidyr to create a nested data frame ---------------------------------------------

library(tidyr)

nested_df=gapminder %>% 
  group_by(country,continent) %>% 
  nest() %>% 
  mutate(fit=map(data,~lm(lifeExp~year,data=.x)))

str(nested_df$fit[1:3],max.level = 1)

nested_df$fit[[3]]

nested_df %>% 
  filter(continent=="Oceania") %>% 
  .$fit

# create a dataframe with country, continent, coeff, intercept and slope

nested_df %>% 
  mutate(coefs=map(fit,coef),intercept=map_dbl(coefs,1),slope=map_dbl(coefs,2)) %>% 
  select(country,continent,intercept, slope)
  