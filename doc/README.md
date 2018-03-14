# Documentation Folder

`main.Rmd` is the main project script. It ties together all the code and accesses purpose-specific scripts. It has the following structure:

1. Set up working directories and file paths.

2. Set up experimental controls for feature extraction. For example, `run.sift <- T` performs SIFT feature extraction, and `run.sift <- F` means not to.

3. Set up experimental controls for model training, with the same structure as the preceding.

4. Make predictions: generate predicted labels for test data using trained models. Confusion matrices are also generated.

5. Summarize running time for the preceding steps.
