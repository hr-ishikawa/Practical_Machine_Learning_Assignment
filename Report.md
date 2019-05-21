## Practial Machine Learning Assignment

# Analysis Predicting manner


```R
library(tidyverse)
library(caret)
library(randomForest)
library(e1071)
library(doParallel)
```

## Pre Process
The sample data sets contains the inappropriate data, such as NA (Blank) or text ("#Div0!") data.
I dropped the coloumns contains inappropriate data from Training and Testing Data.
And factorize the coloumn named "classe" to predict classification.

```R
train <- read_csv('pml-training.csv')
test  <- read_csv('pml-testing.csv' )
train <- train %>% mutate(flag='train')
test  <- test  %>% mutate(flag='test' ) %>% 
          mutate(problem_id=as.character(problem_id)) %>% rename(classe=problem_id)

all  <- bind_rows(train,test) %>% select(names(train)[-c(1,3:7)])
drop <- map_lgl(all[,2:153], function(c){ any(is.na(c))} )      # Drop columns contain NA
all <- all[, c(T,!drop,T,T)]
print(ncol(all))

train <- all %>% filter(flag=='train') %>% select(-flag) %>% mutate(classe=factor(classe))
test  <- all %>% filter(flag=='test')  %>% select(-flag)
```

## Split Data
I splited the Training data to training (80%) and validation (20%), that train acutual and validate the outcome of training.

```R
index <- createDataPartition(train$classe, p=0.8, list=F, times=1)
train.t <- train[ index,]
train.v <- train[-index,]
```

## Fitting
I choiced the Random Forest as model. I applied the cross validation as caret fitting option.
To consider in/out of sample error, I changed Sample size and fitted.

```R
accu <- data.frame()
for(i in c(5,10,15,20,30,50,100)){ # Percent of Training without for validation
    set.seed(0)
    index <- createDataPartition(train.t$classe, p=i/100, list=F, times=1)
    train.x <- train.t[ index,]

        cl <- makeCluster(detectCores()) # for Parallel processing
        registerDoParallel(cl)           #
    #-- Fit ----
    modFit <- train(classe~., method='rf', data=train.x,
                    trControl=trainControl(method = 'cv', number=10))
    #-----------
        stopCluster(cl)                 #

    # Accuracy fitted in sample
    x <- confusionMatrix(predict(modFit,newdata=train.x), train.x$classe)
    # Accuracy out of sample
    v <- confusionMatrix(predict(modFit,newdata=train.v), train.v$classe)

    accu <- bind_rows(accu, 
                      data.frame(n_samples =nrow(train.x),
                                 x_accu=x$overall['Accuracy'], 
                                 v_accu=v$overall['Accuracy']))
}
```

## The outcome
### In/Out of Sample error (Accuracy)
The Accuracies of in Sample and Out of sample shows following table and graph.
In the case of in sample, Accuracy is high even when there are small samples.
But, I case of out of sample, always Accuracy is lower than in sample, especially when sample is small.
That means fitted model is no good when the sample is small.
When sample size is full (Training data without for validation), the out of sample Accuracy is high enough to complete.

```R
print(accu)
p <- ggplot(accu, aes(x=n_samples)) +
     geom_line(aes(y=x_accu, colour='in Sample' ) ) +
     geom_line(aes(y=v_accu, colour='out of Sample') ) +
     scale_colour_manual('Accuracy', values=c('in Sample'='blue', 'out of Sample'='red')) +
     labs(title='The in/out of samples errors and number of samples',
          x='Number of Samples', y='Accuracy')
plot(p)
```

|Number of Samples|Accuracy<br>In Sample|Accuracy<br>Out of Samplpe|
|--:|--:|--:|
|787|1.00|0.89396|
|1572|1.00|0.93500|
|2356|1.00|0.95463|
|3142|1.00|0.96992|
|4712|1.00|0.97476|
|7850|1.00|0.98700|
|15699|1.00|0.99541|

![Accuracy](https://github.com/hr-ishikawa/Practical_Machine_Learning_Assinments/blob/master/Accuracy.PNG "Accuracy")
### Prediction
The outcome of prediction shows following table.

```R
pred <- predict(modFit, newdata=test)
```

|No.| 1| 2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|
|:--|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
|classe|B|A|B|A|A|E|D|B|A|A|B|C|B|A|E|E|A|B|B|B|
