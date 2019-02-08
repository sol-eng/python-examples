library(plumber)
library(reticulate)

#* @apiTitle Sentiment Analysis Text API

source_python('predict.py')

#* @param input Text to classify
#* @get /predict
function(input = "This is happy text!") {
    result = predict(input)
}
