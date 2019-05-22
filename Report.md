## Practial Machine Learning Assignment

# Analysis Predicting manner

## Preparation
```{r}
library(tidyverse)
library(caret)
library(randomForest)
library(doParallel)
```

## Read and Pre-Process of Data Sets
Read The sample data sets to data.frame.
The sample data sets contains the inappropriate data, such as NA (Blank) or text ("#Div0!") data.
I dropped the coloumns contains inappropriate data from Training and Testing Data.
And factorize the target coloumn named "classe" for classification.

```{R}
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
set.seed(0)
index <- createDataPartition(train$classe, p=0.8, list=F, times=1)
train.t <- train[ index,]
train.v <- train[-index,]
```

## Fitting
I choiced the Random Forest as model. I use the cross validation as caret fitting option.
Additional, It spent long time. so, applied parallel processing.

```R
set.seed(0)

    cl <- makeCluster(detectCores()) # for Parallel processing
    registerDoParallel(cl)           #
#-- Fit ----
modFit <- train(classe~., method='rf', data=train.t,
                trControl=trainControl(method = 'cv', number=10))
#-----------
    stopCluster(cl)                 #

```

## The Result
### In/Out of Sample error
First, Caluculate In Sample error.

```R
# In sample
confusionMatrix(predict(modFit,newdata=train.t), train.t$classe)

# Overall Statistics
#               Accuracy : 1
```
In sample error (1 - Accuracy) is 0.0%.
That is so good but overfitting?

Second, Caluculate Out of Sample error.
```R
# Out of sample
confusionMatrix(predict(modFit,newdata=train.v), train.v$classe)

# Overall Statistics
#               Accuracy :  0.994
```
Out of sample error (1 - Accuracy) is 0.6%
That is very close to in sample error, and small enough.
I can judge the fitted model is not overfitting, and good perfomance.

### Prediction
Predict form the test data set.
From analysis below, I can expect the good outcome. 

```R
# Predict from Test set
pred <- predict(modFit, newdata=test)
```
