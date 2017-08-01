# AcuteTBI

## Run the codes
1. (option 1): run *./Modeldata_preparation.m* to build dataset for training or test Change the path of patients data in *./ImageProcess_Scripts/BrainImage_pid.m*
   (option 2): load data: 

2. use ./Model/training_script.m to train and test the model


## Description 

### Model: 
Main scripts to build the dataset, feature extraction, train & test the SVM model

### ImageProcess_Scripts: 
Matlab functions to process brain images, 
including brain extraction, superpixel segmentation, brain padding, etc.

### Acitve_Learning_Scripts: 
Implementing different active learning algorithms. Under development

### Evaluation: 
Matlab functions/scripts to evaluate the model - calculate dice, sensitivity,
specificity, accuracy based on individual patient and build the predicted images.

### Toolbox: toolbox to be installed to run the codes.

