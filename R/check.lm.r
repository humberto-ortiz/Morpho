#' Visually browse through a sample rendering its landmarks and corresponding
#' surfaces.
#' 
#' Browse through a sample rendering its landmarks and corresponding surfaces.
#' This is handy e.g. to check if the landmark projection using placePatch was
#' successful, and to mark specific specimen.
#' 
#' 
#' @param dat.array array or list containing landmark coordinates.
#' @param path optional character: path to files where surface meshes are
#' stored locally. If not specified only landmarks are displayed.
#' @param prefix prefix to attach to the filenames extracted from
#' \code{dimnames(dat.array)[[3]]} (in case of an array), or
#' \code{names(dat.array)} (in case of a list)
#' @param suffix suffix to attach to the filenames extracted from
#' \code{dimnames(dat.array)[[3]]} (in case of an array), or
#' \code{names(dat.array)} (in case of a list)
#' @param col mesh color
#' @param pt.size size of plotted points/spheres. If \code{point="s"}.
#' \code{pt.size} defines the radius of the spheres. If \code{point="p"} it
#' sets the variable \code{size} used in \code{point3d}.
#' @param alpha value between 0 and 1. Sets transparency of mesh 1=opaque 0=
#' fully transparent.
#' @param begin integer: select a specimen to start with.
#' @param render if render="w", a wireframe will be drawn, else the meshes will
#' be shaded.
#' @param point how to render landmarks. "s"=spheres, "p"=points.
#' @param add logical: add to existing rgl window.
#' @param Rdata logical: if the meshes are previously stored as Rdata-files by
#' calling save(), these are simply loaded and rendered. Otherwise it is
#' assumed that the meshes are stored in standard file formats such as PLY, STL
#' or OBJ, that are then imported with the function \code{\link{file2mesh}}.
#' @param atlas provide object generated by \code{\link{createAtlas}} to
#' specify coloring of surface patches, curves and landmarks
#' @param text.lm logical: number landmarks. Only applicable when
#' \code{atlas=NULL}.
#' @return returns an invisible vector of indices of marked specimen.
#' @note if \code{Rdata=FALSE}, the additional command line tools need to be
#' installed
#' (\url{http://sourceforge.net/projects/morpho-rpackage/files/Auxiliaries/})
#' @seealso \code{\link{placePatch}, \link{createAtlas}, \link{plotAtlas},
#' \link{file2mesh}}
#' @keywords ~kwd1 ~kwd2
#' @examples
#' 
#' data(nose)
#' ###create mesh for longnose
#' longnose.mesh <- warp.mesh(shortnose.mesh,shortnose.lm,longnose.lm)
#' ### write meshes to disk
#' save(shortnose.mesh, file="shortnose")
#' save(longnose.mesh, file="longnose")
#' 
#' ## create landmark array
#' data <- bindArr(shortnose.lm, longnose.lm, along=3)
#' dimnames(data)[[3]] <- c("shortnose", "longnose")
#' checkLM(data, path="./",Rdata=TRUE, suffix="")
#' 
#' 
#' ## now visualize by using an atlas:
#' atlas <- createAtlas(shortnose.mesh, landmarks =
#'            shortnose.lm[c(1:5,20:21),],
#' patch=shortnose.lm[-c(1:5,20:21),])
#' \dontrun{
#' checkLM(data, path="./",Rdata=TRUE, suffix="", atlas=atlas)
#' }
#' 
#' @export checkLM
checkLM <- function(dat.array, path=NULL, prefix="", suffix=".ply", col="white", pt.size=NULL, alpha=0.7, begin=1, render=c("w","s"), point=c("s","p"), add=FALSE, Rdata=FALSE, atlas=NULL, text.lm=FALSE)
    {
        k <- NULL
        marked <- NULL
        j <- 1
        if (!Rdata)
            load <- file2mesh
        outid <- NULL
        point <- point[1]
        ## set point/sphere sizes
        radius <- pt.size
        if (is.null(radius)) {
            if (point == "s")
                radius <- (cSize(dat.array[,,1])/sqrt(nrow(dat.array[,,1])))*(1/30)
            else
                radius <- 10
        }
        size <- radius
        render <- render[1]
        arr <- FALSE
        point <- point[1]
        if (point == "s") {
            rendpoint <- spheres3d
        } else if (point == "p") {
            rendpoint <- points3d
        } else {
            stop("argument \"point\" must be \"s\" for spheres or \"p\" for points")
        }
        dimDat <- dim(dat.array)
        if (length(dimDat) == 3) {
            n <- dim(dat.array)[3]
            name <- dimnames(dat.array)[[3]]
            arr <- TRUE
        } else if (is.list(dat.array)) {
            n <- length(dat.array)
            name <- names(dat.array)
        } else {
            stop("data must be 3-dimensional array or a list")
        }
        i <- begin
        if (render=="w") {
            rend <- wire3d
        } else {
            rend <- shade3d
        }
        if (!add || rgl.cur()==0)
            open3d()
        if (!is.null(atlas)) {
            k <- dim(atlas$landmarks)[1]
            #k1 <- dim(atlas$patch)[1]
        }
        while (i <= n) {
            rgl.bringtotop()
            tmp.name <- paste(path,prefix,name[i],suffix,sep="")
            if (arr)
                landmarks <- dat.array[,,i]
            else
                landmarks <- dat.array[[i]]
            if (is.null(atlas)) { 
                outid <- rendpoint(landmarks,radius=radius, size=size)
                if (text.lm)
                    outid <- c(outid, text3d(landmarks, texts=paste(1:dim(landmarks)[1], sep=""), cex=1, adj=c(1,1.5)))
                             
                if (!is.null(path)) {
                    if (!Rdata) {
                        tmpmesh <- file2mesh(tmp.name)
                    } else {
                        input <- load(tmp.name)
                        tmp.name <- gsub(path,"",tmp.name)
                        tmpmesh <- get(input)
                    }
                    
                    outid <- c(outid,rend(tmpmesh,col=col,alpha=alpha))
                    rm(tmpmesh)
                    if (Rdata)
                        rm(list=input)
                    gc()
                }
            } else {
                atlas.tmp <- atlas
                atlas.tmp$mesh <- NULL
                atlas.tmp$landmarks <- landmarks[1:k,]
                atlas.tmp$patch <- landmarks[-c(1:k),]
                
                if (!is.null(path)) {
                    if (!Rdata) {
                        atlas.tmp$mesh <- file2mesh(tmp.name)
                    } else {
                        input <- load(tmp.name)
                        tmp.name <- gsub(path,"",tmp.name)
                        atlas.tmp$mesh <- get(input)
                    }
                }
                outid <- plotAtlas(atlas.tmp, add=TRUE, alpha=alpha, pt.size=radius, render=render, point=point, meshcol=col, legend=FALSE)
                
            }
                
                
                answer <- readline(paste("viewing #",i,"(return=next | m=mark current | s=stop viewing)\n"))
                if (answer == "m") {
                    marked[j] <- i
                    j <- j+1
                } else if (answer == "s") {
                    i <- n+1
                } else
                    i <- i+1
                rgl.pop(id=outid)
            }
            invisible(marked)
        }
