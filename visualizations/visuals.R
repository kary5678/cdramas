ggplot(data=cdramas_df, aes(x=factor(year)))+
  geom_bar()+
  labs(title="Number of Chinese Dramas Released 2012-2021",
       x="Year")

ggplot(data=cdramas_df, aes(x=factor(year), y=eps))+
  geom_boxplot()+
  labs(title="Distribution of Chinese Drama Episode Counts 2012-2022",
       x="Release Year", y="Episode Count")
