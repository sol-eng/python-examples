library(plumber)
library(reticulate)

use_python("/opt/python/bin/python3")

#* @apiTitle Sentiment Analysis Text API

source_python('predict.py')

#* @param input Text to classify
#* @get /predict
function(input = "") {
    result = predict(input)
}
