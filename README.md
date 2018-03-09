# Cat or Dog: Prediction & Model Assessment

## Columbia University, Department of Statistics | STAT GU4243,  Applied Data Science | Spring, 2018

### [Final Project Presentation](doc/Presentation/ADS_P2_G6_Presentation.pdf)

### [Original Project Assignment](doc/project2_desc.md)

### Project summary
#### Given 
+ 2,000 images labeled as cat or dog.
+ A baseline feature extraction using the scale-invariant feature transform (SIFT).
+ A baseline statistical machine learning model, a gradient boosting machine, trained on those SIFT features.
#### To-do
Produce a portable AI module that can predict whether a new image is a cat or a dog. 
#### Spec
Improve on the accuracy performance of the baseline model by exploring other feature extractions and other predictive models. Keep in mind computational costs of feature extraction, model training, and prediction time.

### Team Members
Wanting Cheng, Mingkai Deng, Jiongjiong Li, Kai Li, and Daniel Parker

### File Structure
This project repository is organized as followed.
#### Data
A separate local data directory, because the image data are too large to keep on Github.
```
data/
```
#### GitHub repository
```
GitHub_project/
├──README.md      # Basic summary and description.
├──doc/           # 
├────main.RMD     # The main project script. Ties together all the project code, and accesses the purpose-specific scripts.
├──figs/          # Any figures and graphics produced.
├──lib/           # The project library, containing any purpose-specific scripts.
├────feature.R    # Extracts features from an input image directory.
├────train.R      # Trains several statistical machine learning models, based on input feature data.
├────test.R       # Returns predictions of input test images.
├──output/        # Contains 
```
Particular files that might be interest to look at:
[`doc/main.Rmd`](doc/main.Rmd) 

[`lib/feature.R`](lib/feature.R)

[`lib/train.R`](lib/train.R) 

[`lib/test.R`](lib/test.R) 

### Contributions
#### Feature extraction
+ WC: red, green, and blue (RGB); hue, saturation, and value (HSV); local binary patterns (LBP)
+ MG: scale-invariant feature transform (SIFT)
+ JL: histogram of oriented gradients (HOG)
+ KL: rotation
#### Machine learning models
+ WC: support vector machine
+ JL: gradient boosting machine, adaptive gradient boosting, extreme gradient boosting
+ KL: neural network
+ DP: random forests
#### Project architecture and code finalization
+ WC: finalized all the scripts and compiled code
+ MD: precision-recall analysis
+ JL: randomized split of training data, for 
+ KL: original `README.md` 
+ DP: edited and refactored code for personal GitHub version
#### Project management
+ DP: scheduled meetings, took notes, guided project workflow
#### Presentation slides
+ MD: contributed performance data
+ DP: wrote entire presentation in LaTeX using `beamer` package
