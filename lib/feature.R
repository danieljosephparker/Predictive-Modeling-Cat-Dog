################################################################
### Extract visual features for input images                 ###
### Authors: Wanting Cheng, Jiongjiong Li, and Daniel Parker ###
################################################################

img_dir <- "/Users/djparker/Documents/Temp/Juilliard/Spring 2018/ADS_STAT_4243/Project_2/train/"

feature <- function(img_dir, 
                    run.color = F,
                    run.LBP = F,
                    run.HOG = F,
                    export = T){
  
  # Extract visual features for input images
  # Sample simple feature: extract row average raw pixel values as features
  
  # Input: a directory that contains images ready for processing
  #   In this project, the number of training images was 2000,
  #   and the number of test images was 1850.
  
  # Output: .RData files of extracted image features: 
  #   1. Color features: red, green, blue (RGB) and hue, saturation, and value (HSV)
  #   2. Gray features: local binary patterns (LBP)
  #   3. Histogram of oriented gradients (HOG)
  
  if(run.color){color <- color_extract(img_dir, export = T)}
  if(run.LBP){LBP <- LBP_extract(img_dir, export = T)}
  if(run.HOG){HOG <- HOG_extract(img_dir, export = T)}
}

color_extract <- function(img_dir, export = T){
  start_time = Sys.time() # Record time at beginning of extraction
 
  # Load libraries
  require("EBImage")
  require("plyr")
  require(reticulate)
  require("wvtool")
  cv2 <- reticulate::import('cv2')
  
  # Set parameters
  n_resize <- 128 # Uniform image size
  n_intervals <- 10 # Levels for RGB intensity
  intervals_RGB <- seq(0, 1, length.out = n_intervals) # Color level limits
  intervals_value <- seq(0, 0.005, length.out = n_intervals) # Value (HSV) level limits
  
  # Determine total number of input image files
  n_files <- length(list.files(img_dir))
  
  # Reproduce names of input images
  pet_names <- paste("pet", 1:n_files, ".jpg", sep = "")
 
   # Make progress bar
  pb <- txtProgressBar(min = 0, max = n_files, style = 3)

  # Construct the RGB feature matrix
  RGB <- data.frame(matrix(NA, n_files, n_intervals^3+11))
  # Set up column names
  colnames(RGB) <- c("Image", paste("RGB_", 1:n_intervals^3, sep = ""))
  # Set up initial column of preserved file names
  RGB$Image <- pet_names
    
  # Construct the HSV feature matrix
  HSV <- data.frame(matrix(NA, n_files, n_intervals^3+1))
  # Set up column names
  colnames(HSV) <- c("Image", paste("HSV_", 1:n_intervals^3, sep = ""))
  # Set up initial column of preserved file names
  HSV$Image <- pet_names
  
  # Calculate color values for each image and store them
  for(i in 1:n_files){
    img <- readImage(paste(img_dir, pet_names[i], sep = ""))  # Read in the image
    img <- resize(img, n_resize, n_resize)                    # Resize
    img_data <- imageData(img)
      
    # RGB
    RGB_data <- img_data
    RGB_levels <- as.data.frame(table(
      factor(findInterval(RGB_data[,,1], intervals_RGB), levels = 1:n_intervals),
      factor(findInterval(RGB_data[,,2], intervals_RGB), levels = 1:n_intervals),
      factor(findInterval(RGB_data[,,3], intervals_RGB), levels = 1:n_intervals)))
    RGB[i,2:ncol(RGB)] <- RGB_levels$Freq/(n_resize^2)
      
    # HSV
    dim(img_data) <- c(n_resize*n_resize,3) # Set the dimension of the image matrix to convert to HSV format
    HSV_data <- rgb2hsv(t(img_data))
    HSV_levels <- as.data.frame(table(
      factor(findInterval(HSV_data[1,], intervals_RGB), levels = 1:n_intervals),
      factor(findInterval(HSV_data[2,], intervals_RGB), levels = 1:n_intervals),
      factor(findInterval(HSV_data[3,], intervals_value), levels = 1:n_intervals)))
    HSV[i,2:ncol(HSV)] <- HSV_levels$Freq/(n_resize^2)
      
    # Update progress bar
    setTxtProgressBar(pb, i)
  }
  
  color_features <- join(RGB, HSV)
  
  close(pb)
  
  end_time = Sys.time() # Record time at end of extraction
  build_time_color = end_time - start_time # Compute total extraction time
  
  # Save extracted features to output directory
  if(export){
    save(color_features, file = "../output/train_feature_color.RData")
    save(build_time_color, file = "../output/train_feature_color_time.RData")}

  # Return main dataframe
  return(color_features)
}

LBP_extract <- function(img_dir, export = T){
  # 15.8303 min on my computer
  
  start_time = Sys.time() # Record time at beginning of extraction
  
  # Load libraries
  require("EBImage")
  require("plyr")
  require(reticulate)
  require("wvtool")
  cv2 <- reticulate::import('cv2')
  
  # Set parameters
  n_resize <- 128       # Uniform image size
  n_intervals_LBP <- 30 # Number of LBP intensity levels
  intervals_LBP <- seq(0, 255, length.out = n_intervals_LBP) # Feature level limits
  
  # Determine total number of input image files
  n_files <- length(list.files(img_dir))
  
  # Reproduce names of input images
  pet_names <- paste("pet", 1:n_files, ".jpg", sep = "")
  
  # Make progress bar
  pb <- txtProgressBar(min = 0, max = n_files, style = 3) 
  
  # Initialize empty dataframe with n_files rows and n_intervals_LBP columns
  LBP <- data.frame(matrix(NA, n_files, n_intervals_LBP+1))
  # Set up column names according to the n_intervals_LBP features
  colnames(LBP) <- c("Image", paste("LBP_", 1:n_intervals_LBP, sep = ""))
  # Set up initial column of preserved file names
  LBP$Image <- pet_names
  
  # Calculate LBP values for each image and store them
  for(i in 1:n_files){
    img <- readImage(paste(img_dir, pet_names[i], sep = ""))  # Read in the image
    img <- resize(img, n_resize, n_resize)                    # Resize
    img_gray <- cv2$cvtColor(np_array(img, dtype='float32'), cv2$COLOR_BGR2GRAY) # Convert to greyscale
    lbp_data <- lbp(img_gray)$lbp.ori
    lbp_levels <- as.data.frame(table(factor(
          findInterval(lbp_data, intervals_LBP), levels = 1:n_intervals_LBP))) # Compute LBP values
    LBP[i, 2:ncol(LBP)] <- lbp_levels$Freq/(n_resize^2) # Input into appropriate row of main dataframe
    # Update progress bar
    setTxtProgressBar(pb, i)
  }
  
  close(pb)

  end_time = Sys.time() # Record time at end of extraction
  build_time_LBP = end_time - start_time # Compute total extraction time
  
  # Save extracted features to output directory
  if(export){
    save(LBP, file = "../output/train_feature_LBP.RData")
    save(build_time_LBP, file = "../output/train_feature_LBP_time.RData")}
  
  # Return main dataframe
  return(LBP)
}


HOG_extract <- function(img_dir, export = T){
  start_time = Sys.time() # Record time at beginning of extraction

  # Load libraries
  require("EBImage")
  require("plyr")
  require(reticulate)
  require("wvtool")
  cv2 <- reticulate::import('cv2')
  
  # Set parameters
  winSize <- tuple(64L,64L)     # Resize images
  blockSize <- tuple(16L,16L)   # Size of one block
  blockStride <- tuple(8L,8L)   # Length everytime block moves
  cellSize <- tuple(8L,8L)      # Size of one cell
  nbins = 9L                   # Number of orientations
  
  # Determine total number of input image files
  n_files <- length(list.files(img_dir))
  
  # Reproduce names of input images
  pet_names <- paste("pet", 1:n_files, ".jpg", sep = "")
  
  # Make progress bar
  pb <- txtProgressBar(min = 0, max = n_files, style = 3) 
  
  # Initialize HOG Descriptor
  HOG_desc = cv2$HOGDescriptor(winSize,
                          blockSize,
                          blockStride,
                          cellSize,
                          nbins)
  
  # Initialize empty dataframe with n_files rows and 1765 columns
  HOG <- data.frame(matrix(NA, n_files, ncol = 1765))
  # Set up column names according to the 1764 HOG features
  colnames(HOG) <- c("Image", paste("HOG_", 1:1764, sep = ""))
  # Set up initial column of preserved file names
  HOG$Image <- pet_names
  
  # Calculate HOG values for each image and store them
  for(i in 1:n_files){
    img <- cv2$imread(paste(img_dir, "pet", i, ".jpg", sep = ""))/255       # Read in the image
    img_resized <- cv2$resize(img, dsize = tuple(64L, 64L))                 # Resize
    HOG_val <- HOG_desc$compute(np_array(img_resized * 255, dtype='uint8')) # Compute HOG values
    HOG[i,2:1765] <- HOG_val                        # Input into appropriate row of main dataframe
    # Update progress bar
    setTxtProgressBar(pb, i)
  }
  
  close(pb)
  
  end_time = Sys.time() # Record time at end of extraction
  build_time_HOG = end_time - start_time  # Compute total extraction time
  
  # Save extracted features to output directory
  if(export){
    save(HOG, file = "../output/train_feature_HOG.RData")
    save(build_time_HOG, file = "../output/train_feature_HOG_time.RData")}
  
  # Return main dataframe
  return(HOG)
}

