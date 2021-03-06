#install.packages('colormap')

library(ggplot2)
library(colormap)
library(magick)
library(ggraph)
library(igraph)
library(reshape2)
library(plyr)
library(EvoFreq)
library(colorspace)
library(gridExtra)

#### all files params ###
ending_timepoint <- 1000
custom_colors <- c("#3874b1", "#c6382c","#4f9f39", "#bdbe3a","#8e66ba","#f08627","#53bbce", "#d67bbf","#85584c", "#b2c5e6","#f39c97", "#a6de90","#dcdc93","#c2aed3","#f6bf7e","#a9d8e4","#eeb8d1","#be9d92","#c7c7c7","#7f7f7f")
c_pallete <- custom_colors

setwd('~/Documents/GitHub/passenger-driver/data-output/')

clone_history_file <- paste("./clones.csv", sep = "")
clone_parents_file <- paste("./parents.csv", sep = "")
clone_driver_file <- paste("./driverStatus.csv", sep = "")

clone_df <- read.csv(clone_history_file, check.names = F, header = T)
parent_list <- as.numeric(read.csv(clone_parents_file, check.names = F, header = F))
clone_list <- as.numeric(row.names(clone_df))
time_pts <- colnames(clone_df)

pos_df <- get_freq_dynamics(clone_df, clones = clone_list, parents = parent_list, threshold=0.1,scale_by_sizes_at_time = F, clone_cmap =c_pallete, time_pts=as.numeric(time_pts),interpolation_steps = 0)

driver_vec = as.numeric(read.table(clone_driver_file, sep=",", check.names = F, header = F))
driver_nonzero = which(driver_vec!=0)
driver_ids = clone_list[driver_nonzero]
driver_strength = driver_vec[driver_nonzero]

pos_out_df <- as.data.frame(matrix(NA,ncol=length(colnames(pos_df))+2, nrow=0))
colnames(pos_out_df) <- c(colnames(pos_df), "driv_stat", "alpha")
for(i in 1:length(unique(pos_df$clone_id))){
  tmp <- subset(pos_df, pos_df$clone_id==unique(pos_df$clone_id)[i])
  tmp$driv_stat = driver_strength[which(unique(pos_df$clone_id)[i]==driver_ids)]
  color_iterator = unique(tmp$driv_stat)
  tmp$color = c_pallete[color_iterator]
  pos_out_df <- rbind(pos_out_df, tmp)
}

fp <- plot_freq_dynamics(pos_out_df, bw=0.06, bc="black", end_time = ending_timepoint)
fp <- fp + theme_minimal()
fp <- fp + scale_x_continuous(limits=c(0,ending_timepoint)) # remove labels
fp <- fp + theme() + ylab("Frequency") + scale_y_continuous(limits=c(0,1))
fp <- fp + guides(fill=F, color=F, alpha=F) + xlab("Time")
print(fp)

ggsave(paste(1,"fishy.png", sep = ""), fp, width = 15, height = 3, units = "in")
