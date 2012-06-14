check.lm <- function(dat.array,path=NULL,prefix="",suffix=".ply",col=3,radius=1,alpha=0.7,begin=1,render="w",point=c("s","p"),add=FALSE)
  {
    outid <- NULL
    point=point[1]
    arr <- FALSE
    if (point == "s")
      {rendpoint <- spheres3d
     }
    else if (point == "p")
      {rendpoint <- points3d
     }
    else
      {
        stop("argument \"point\" must be \"s\" for spheres or \"p\" for points")
      }
    dimDat <- dim(dat.array)
    if (length(dimDat) == 3)
      {
        n <- dim(dat.array)[3]
        name <- dimnames(dat.array)[[3]]
        arr <- TRUE
      }
    else if (is.list(dat.array))
      {
        n <- length(dat.array)
        name <- names(dat.array)
      }
    else
      {
        stop("data must be 3-dimensional array or a list")
      }
    i <- begin
    if (render=="w")
      {rend <- wire3d
     }
    else
      {
        rend <- shade3d
      }
    if (!add)
      {
        open3d()
      }
        while (i <= n)
      {
        tmp.name <- paste(path,prefix,name[i],suffix,sep="")
        if (arr)
          {
            outid <- rendpoint(dat.array[,,i],radius=radius)
          }
        else
          {
            outid <- rendpoint(dat.array[[i]],radius=radius)
          }
        
        if (!is.null(path))
          {
            tmpmesh <- file2mesh(tmp.name)
            outid <- c(outid,rend(tmpmesh,col=col,alpha=alpha))
            rm(tmpmesh)
            gc()
          }
        answer <- readline(paste("viewing #",i,"next"))
        i <- i+1
        rgl.pop(id=outid)
      }
  }
