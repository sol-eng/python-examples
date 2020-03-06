import spacy
from flask import Flask, jsonify, render_template, request
app = Flask(__name__)

model_dir = "model"

@app.route('/')
def page():
   return render_template("app.html")

@app.route('/sentiment', methods = ['POST', 'GET'])
def predict():
    if request.method == "POST":
        input = request.form["input"]
        print(input)
        nlp = spacy.load(model_dir)
        doc = nlp(input)
        sentiment = (input, doc.cats)
        return render_template("result.html", input = input, sentiment = sentiment)

if __name__ == '__main__':
   app.run(debug = True)
