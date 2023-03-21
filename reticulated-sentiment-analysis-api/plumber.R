library(plumber)
library(reticulate)

#* @apiTitle Sentiment Analysis Text API
#* @apiDescription A Plumber API that uses R and Python to evaluate sentiment in
#* text input using a pretrained spaCy model

source_python('predict.py')

#* @param input Text to classify
#* @get /predict
function(input = "This is happy text!") {
    result = predict(input)
}
