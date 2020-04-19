library(data.table)

setwd("~/Desktop/Statistics Personal Notes/COVID/datasets-sample/2011 OAC Local Authorities")

LA.file.list <- dir("Local Authority CSV Files")
LA.name.list <- gsub(".csv", "", LA.file.list)

dt <- as.data.table(LA.name.list)
setnames(dt, "LA.name.list", "Local Authorities")

dt[, c(as.character(seq(1, 8))):=0]

for (loc.auth in LA.file.list){
  temp.data <- fread(file.path("Local Authority CSV Files", loc.auth))
  
  temp.data[, SPRGRP:=as.factor(SPRGRP)]
  temp.data <- temp.data[, .(.N/nrow(temp.data)), by=SPRGRP]
  
  temp.data <- dcast(melt(temp.data[order(SPRGRP), ], id.vars = "SPRGRP"), 
                     variable ~ SPRGRP)
  
  temp.data[, variable:=NULL]
  
  dt[`Local Authorities`==gsub(".csv", "", loc.auth), 
     c(colnames(temp.data)):=temp.data]
}

write.csv(dt, "Personas OAC 2011.csv")
