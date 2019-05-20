# Practial Machine Learning Assignment

# Analysis Predicting manner

## Pre Process
The sample data sets contains the inappropriate data, such as NA (Blank) or text ("#Div0!") data.
I dropped the coloumns contains inappropriate data from Training and Testing Data.
And factorize the coloumn named "classe" to predict classification.

## Split Data
I splited the Training data to training (80%) and validation (20%), that train acutual and validate the outcome of training.

## Fitting
I choiced the Random Forest as model. I applied the cross validation as caret fitting parameter.
To consider in/out of sample error, 

## Resuls
### In/Out of Sample error
![Accuracy](https://github.com/hr-ishikawa/Practical_Machine_Learning_Assinments/blob/master/Accuracy.PNG "Accuracy")
### prediction



