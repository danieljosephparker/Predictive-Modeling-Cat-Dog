# Cat or Dog: Predictive Modelling and Computation Time Optimization

## Columbia University, Department of Statistics | STAT GU4243,  Applied Data Science | Spring, 2018

### [Final Project Presentation](doc/Presentation/ADS_P2_G6_Presentation.pdf)

### [Original Project Assignment](doc/project2_desc.md)

### Team Members
Wanting Cheng, Mingkai Deng, Jiongjiong Li, Kai Li, Daniel Parker

### File Structure
[`doc/main.R`](doc/main.R) is the main file wrapper. It ties together all the project code.

[`lib/feature.R`](lib/feature.R)/lib/feature.R extracts features from an input image directory.

[`lib/train.R`](lib/train.R) trains several statistical machine learning models, based on input feature data.

[`lib/test.R`](lib/test.R) returns predictions of input test images.

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
