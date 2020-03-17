import pickle as p
import pandas as pd
from sklearn import datasets, linear_model

# Import CSV of mtcars dataset
data = pd.read_csv('https://gist.githubusercontent.com/ZeccaLehn/4e06d2575eb9589dbe8c365d61cb056c/raw/64f1660f38ef523b2a1a13be77b002b98665cdfe/mtcars.csv')

# train a simple liner model
X = data[['cyl', 'hp']]
y = data['mpg']
m = linear_model.LinearRegression().fit(X,y)

# save the model to disk to deploy with our API
p.dump( m, open( "model.p", "wb" ) )
