library(tidyverse)
library(caret)
library(randomForest)
library(e1071)
library(doParallel)

options(digits=5)
options(warn=-1)
options(width=100)

R.Version()$version.string
print(map_chr(c('tidyverse','caret','randomForest','e1071'),
              function(x){paste(x,': ',packageVersion(x),', ',sep='')}), quote=F)

#============================
# Read Data

train <- read_csv('pml-training.csv')
test  <- read_csv('pml-testing.csv' )

#============================
# Pre Process Sample Date

train <- train %>% mutate(flag='train')
test  <- test  %>% mutate(flag='test' ) %>% 
          mutate(problem_id=as.character(problem_id)) %>% rename(classe=problem_id)

all  <- bind_rows(train,test) %>% select(names(train)[-c(1,3:7)])
drop <- map_lgl(all[,2:153], function(c){ any(is.na(c))} )      # Drop columns contain NA
all <- all[, c(T,!drop,T,T)]
print(ncol(all))

train <- all %>% filter(flag=='train') %>% select(-flag) %>% mutate(classe=factor(classe))
test  <- all %>% filter(flag=='test')  %>% select(-flag)

#============================
# Split Training Data to train, valid

index <- createDataPartition(train$classe, p=0.8, list=F, times=1)
train.t <- train[ index,]
train.v <- train[-index,]

#============================
# Fit randomForest
# Change the number of samples and observe the errors that in and out of sample

accu <- data.frame()
for(i in c(5,10,15,20,30,50,100)){ # Percent of Test set
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

#============================
# Model 

print(accu)
cat('\n== In Sampe ======== Accuracy and ConfusionMatrix\n')
print(x$overall['Accuracy'])
print(x$table)
cat('\n== Out of Sampe ==== Accuracy and ConfusionMatrix\n')
print(v$overall['Accuracy'])
print(v$table)

#============================
# Visualize

p <- ggplot(accu, aes(x=n_samples)) +
     geom_line(aes(y=x_accu, colour='in Sample' ) ) +
     geom_line(aes(y=v_accu, colour='out of Sample') ) +
     scale_colour_manual('Accuracy', values=c('in Sample'='blue', 'out of Sample'='red')) +
     labs(title='The in/out of samples errors and number of samples',
          x='Number of Samples', y='Accuracy')
plot(p)

#============================
# Predict from Test set

pred <- predict(modFit, newdata=test)
print(pred)
