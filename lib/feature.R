################################################################
### Extract visual features for input images                 ###
### Authors: Wanting Cheng, Jiongjiong Li, and Daniel Parker ###
################################################################

feature <- function(img_dir, 
                    run.color = F,
                    run.LBP = F,
                    run.HOG = F,
                    export = F){
  
# Extract visual features for input images
# Sample simple feature: extract row average raw pixel values as features
  
# Input: a directory that contains images ready for processing
#   In this project, the number of training images was 2000,
#   and the number of test images was 1850.
  
# Output: an .RData file of extracted image features: 
#   1. Color features: red, green, blue (RGB) and hue, saturation, and value (HSV)
#   2. Gray features: local binary patterns (LBP)
#   3. Histogram of oriented gradients (HOG)
  
  # Load libraries
  require("EBImage")
  require("plyr")
  require(reticulate)
  require("wvtool")
  cv2 <- reticulate::import('cv2')
  
  if(run.color){color <- color_extract(img_dir, export = T)}
  if(run.LBP){LBP <- LBP_extract(img_dir, export = T)}
  if(run.HOG){HOG <- HOG_extract(img_dir, export = T)}
}

color_extract <- function(img_dir, export = T){
  
  ### Takes about 7min in total
  
  
    # Set the parameters for visual feature extractions
    n_resize <- 128 # the uniform size we want for all the images
    n_intervals <- 10 # How many levels we want to set for red/green/blue intensity

    
    n_files <- length(list.files(img_dir)) # number of files in the directory
    n_names <- paste0( "pet", 1:n_files, ".jpg") # the names of all the images in the directory
    intervals_RGB <- seq(0,1,length.out = n_intervals) # the limits for the levels
    intervals_value <- seq(0,0.005, length.out = n_intervals) # the limits for the levels for the V in HSV
    pb <- txtProgressBar(min = 0, max = n_files, style = 3) # Make a progress bar
    
    
    # Construct the RGB feature matrix and rename the columns and rows.
    RGB <- data.frame(matrix(NA, n_files, n_intervals^3+1))
    colnames(RGB) <- c("Image", paste("RGB_", 1:n_intervals^3, sep = ""))
    RGB$Image <- n_names
    
    # Construct the HSV feature matrix and rename the columns and rows.
    HSV <- data.frame(matrix(NA, n_files, n_intervals^3+1))
    colnames(HSV) <- c("Image", paste("HSV_", 1:n_intervals^3, sep = ""))
    HSV$Image <- n_names
    
    # Then run a loop to read all the images, resize them, and factor out their color intensity to store in the feature matrix.
    for(i in 1:n_files){
      
      img <- readImage(paste(img_dir, n_names[i], sep = ""))
      img <- resize(img, n_resize, n_resize)
      img_data <- imageData(img)
      
      # RGB
      RGB_data <- img_data
      RGB_levels <- as.data.frame(table(
        factor(findInterval(RGB_data[,,1], intervals_RGB), levels = 1:n_intervals),
        factor(findInterval(RGB_data[,,2], intervals_RGB), levels = 1:n_intervals),
        factor(findInterval(RGB_data[,,3], intervals_RGB), levels = 1:n_intervals)
      ))
      RGB[i,2:ncol(RGB)] <- RGB_levels$Freq/(n_resize^2)
      
      # HSV
      # We have to set the dimension of the img matrix to convert the rgb to hsv format.
      dim(img_data) <- c(n_resize*n_resize,3)
      HSV_data <- rgb2hsv(t(img_data))
      HSV_levels <- as.data.frame(table(
        factor(findInterval(HSV_data[1,], intervals_RGB), levels = 1:n_intervals),
        factor(findInterval(HSV_data[2,], intervals_RGB), levels = 1:n_intervals),
        factor(findInterval(HSV_data[3,], intervals_value), levels = 1:n_intervals)
      ))
      HSV[i,2:ncol(HSV)] <- HSV_levels$Freq/(n_resize^2)
      # update progress bar
      setTxtProgressBar(pb, i)
      
    }
    close(pb)
    color_features <- join(RGB, HSV)
    
    # Save extracted features to output directory
    if(export){save(color_features, file = "../output/train_feature_color.RData")}
    
    # Return main dataframe
    return(color_features)
}

LBP_extract <- function(img_dir, export = T){
  
  ### Takes about 20min in total
  
  
  # Set the parameters for visual feature extractions
  n_resize <- 128 # the uniform size we want for all the images
  n_intervals_LBP <- 30 # How many levels we want to set for LBP intensity
  n_files <- length(list.files(img_dir)) # number of files in the directory
  n_names <- paste0( "pet", 1:n_files, ".jpg") # the names of all the images in the directory
  intervals_LBP <- seq(0,255, length.out = n_intervals_LBP) # the limits for the levels for LBP features
  pb <- txtProgressBar(min = 0, max = n_files, style = 3) # Make a progress bar
  
  # Construct the LBP feature matrix and rename the columns and rows.
  LBP <- data.frame(matrix(NA, n_files, n_intervals_LBP+1))
  colnames(LBP) <- c("Image", paste("LBP_", 1:n_intervals_LBP, sep = ""))
  LBP$Image <- n_names
  
  # Then run a loop to read all the images, resize them, and factor out their color intensity to store in the feature matrix.
  for(i in 1:n_files){
    
    img <- readImage(paste(img_dir, n_names[i], sep = ""))
    img <- resize(img, n_resize, n_resize)
    img_data <- imageData(img)
    
    # LBP
    img_gray <- cv2$cvtColor(np_array(img, dtype='float32'), cv2$COLOR_BGR2GRAY)
    lbp_data <- lbp(img_gray)$lbp.ori
    lbp_levels <- as.data.frame(table(
      factor(findInterval(lbp_data, intervals_LBP), levels = 1:n_intervals_LBP)
    ))
    LBP[i, 2:ncol(LBP)] <- lbp_levels$Freq/(n_resize^2)
    # update progress bar
    setTxtProgressBar(pb, i)
  }
  close(pb)

  # Save extracted features to output directory
  if(export){save(LBP, file = "../output/train_feature_LBP.RData")}

  # Return main dataframe
  return(LBP)
}


HOG_extract <- function(img_dir, export = T){
  
  # Set HOG parameters
  # Resize images
  winSize <- tuple(64,64)
  # Size of one block
  blockSize <- tuple(16,16)
  # Length everytime block moves
  blockStride <- tuple(8,8)
  # Size of one cell
  cellSize <- tuple(8,8)
  # Number of orientations
  nbins = 9
  
  # Initialize HOG Descriptor
  HOG_desc = cv2$HOGDescriptor(winSize,
                          blockSize,
                          blockStride,
                          cellSize,
                          nbins)
  
  # Determine total number of input image files
  n_files <- length(list.files(img_dir))
  
  # Reproduce names of input images
  pet_names <- paste("pet", 1:n_files, ".jpg", sep = "")
  
  # Calculate HOG values and store them
  
  # Initialize empty dataframe with n_files rows and 1765 columns
  HOG <- data.frame(matrix(NA, n_files, ncol = 1765))
  # Set up column names according to the 1764 HOG features
  colnames(HOG) <- c("Image", paste("HOG_", 1:1764, sep = ""))
  # Set up initial column of preserved file names
  HOG$Image <- pet_names
  
  for(i in 1:n_files){
    # Read in the image
    img <- cv2$imread(paste(img_dir, "pet", i, ".jpg", sep = ""))/255
    # Resize the graph
    img_resized <- cv2$resize(img, dsize = tuple(64, 64))
    # Compute HOG values
    HOG_val <- HOG_desc$compute(np_array(img_resized * 255, dtype='uint8'))
    # Input into appropriate row of main dataframe
    HOG[i,2:1765] <- HOG_val
  }

  # Save extracted features to output directory
  if(export){save(HOG, file = paste("../output/feature_HOG", ".RData", sep = ""))}
  
  # Return main dataframe
  return(HOG)
}

