## Practial Machine Learning Assignment

# Analysis Predicting manner

## Pre Process
The sample data sets contains the inappropriate data, such as NA (Blank) or text ("#Div0!") data.
I dropped the coloumns contains inappropriate data from Training and Testing Data.
And factorize the coloumn named "classe" to predict classification.

## Split Data
I splited the Training data to training (80%) and validation (20%), that train acutual and validate the outcome of training.

## Fitting
I choiced the Random Forest as model. I applied the cross validation as caret fitting parameter.
To consider in/out of sample error, I changed Sample size and fitted.

## The outcome
### In/Out of Sample error (Accuracy)

|Number of Samples|Accuracy|Accuracy|
||In Sample|Out of Samplpe|
|--:|--:|--:|--:|
|787|1.00|0.89396|
|1572|1.00|0.93500|
|2356|1.00|0.95463|
|3142|1.00|0.96992|
|4712|1.00|0.97476|
|7850|1.00|0.98700|
|15699|1.00|0.99541|

![Accuracy](https://github.com/hr-ishikawa/Practical_Machine_Learning_Assinments/blob/master/Accuracy.PNG "Accuracy")
### prediction
|No.|1|2|3|4|5|6|7|8|9|11|12|13|14|15|16|17|18|19|20|
|:-|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
|classe|B|A|B|A|A|E|D|B|A|A|B|C|B|A|E|E|A|B|B|B|

|左揃え|中央揃え|右揃え|
|:---|:---:|--:|
|align-left|align-center|align-right|
|セルの左揃えです|セルの中央揃えです|セルの右揃えです|
