import json
from sklearn import linear_model
import pickle
from flask import Flask, request
from flask_restx import Api, Resource, fields

# loads our model
# TODO: Replace with getting a pin!
m = pickle.load(open("model.p", "rb"))

# define the flask-restx stuff
app = Flask(__name__)
api = Api(
    app, version="0.1.0", title="MPG API", description="mtcars predict mpg"
)

# defines the main subroute for requests
ns = api.namespace("predict", description="predict mpg based on attributes")

# defines the API response
mpg_predict = api.model(
    "MPG Prediction",
    {
        "hp": fields.Integer(required=True, description="Horsepower of new car"),
        "cyl": fields.Integer(required=True, description="Number of cylinders in new car"),
        "mpg": fields.Integer(description = "Predicted MPG")
    },
)


#served at route + namespace, so at /predict
@ns.route("/")
@ns.param("data", "JSON containing hp and cyl", _in = "body")
class Predict(Resource):
    @ns.marshal_with(mpg_predict)
    @ns.doc("get mpg for inputs")
    def post(self):
        json_data = request.get_json(force=True)
        hp = int(json_data['hp'])
        cyl = int(json_data['cyl'])
        mpg = m.predict([[cyl, hp]])
        return {"hp": hp, "cyl": cyl, "mpg": mpg}
        
#served at route + namespace, so at /predict/cyl6/<user's hp input>
@ns.route("/cyl6/<int:hp>")
@ns.param("hp", "JSON containing hp and cyl")
class Predict(Resource):
    @ns.marshal_with(mpg_predict)
    @ns.doc("get mpg for 6 cyl vehicle")
    def get(self, hp):
        cyl = 6
        mpg = m.predict([[cyl, hp]])
        return {"hp": hp, "cyl": cyl, "mpg": mpg}


