import pickle as p
import pandas as pd
from sklearn import datasets, linear_model

# Import CSV of mtcars dataset
data = pd.read_csv("mtcars.csv")

# train a simple liner model
X = data[["cyl", "hp"]]
y = data["mpg"]
m = linear_model.LinearRegression().fit(X, y)

# save the model to disk to deploy with our API
p.dump(m, open("model.p", "wb"))
