library(arules)
library(cluster)

trim <- function( x ) {
  gsub("(^[[:space:]]+|[[:space:]]+$)", "", x)
}

jaccard <- function(x, y) {
	length(intersect(x,y)) / length(union(x, y))
}

file <- readLines("first_elem.txt", n = -1L, ok = TRUE, warn = TRUE)

split <- strsplit(file, " | ", fixed=TRUE)
split <- lapply(split, function(x) trim(x))

sets <- lapply(split, function(x) unlist(strsplit(x[2], ",")) )
names(sets) <- unlist(lapply(split, function(x) x[1]))

dissim <- data.frame()
for (el in sets) {
	row <- unlist(lapply(sets, function(x) jaccard(el, x)))
	dissim <- rbind(dissim, row) 
}
n <- dim(dissim)[1]
dissim <- dissim[1:(n-1),1:(n-1)]

names(dissim) <- names(sets)[1:(n-1)]
row.names(dissim) <- names(sets)[1:(n-1)]
#save(dissim, file="sim_jaccard.RData")

dissim <- as.matrix(dissim)
dissim <- 1 - dissim
dissim <- as.dist(dissim)


clust <- pam(dissim, 10, diss = TRUE, medoids = NULL, cluster.only = FALSE,
        do.swap = TRUE, pamonce = FALSE, trace.lev = 0)

clust2 <- fanny(dissim, 4, diss = TRUE, memb.exp = 1.07,
          iniMem.p = NULL, cluster.only = FALSE,
          maxit = 1500, tol = 1e-15, trace.lev = 0)