# Project 1: 
### Doc folder

The doc contains the main.Rmd file, which wraps together all the functions and other code used in this project. It has the following structure:

1. Load the directory of image data. Modify according to where it's stored on the computer of the user reproducing the results.

2. Set control variables to TRUE or FALSE to determine whether feature extraction and model training are executed. For example, `run.sift <- T` means SIFT feature extraction is performed, and F means it is not. 

3. Execute feature extraction, if TRUE.

4. Train models, if TRUE.

5. Model selection: optimize model parameters.

6. Generate predictions and confusion matrices.

7. Summarize running time, to aid in model evaluation.