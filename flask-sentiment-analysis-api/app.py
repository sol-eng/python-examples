import spacy
from flask import Flask, request, jsonify
app = Flask(__name__)

model_dir = "model"

@app.route('/')
def predict():
    input = request.args.get("input", "This is a wonderful movie!")
    nlp = spacy.load(model_dir)
    doc = nlp(input)
    result = (input, doc.cats)
    return jsonify(result)

if __name__ == '__main__':
    app.run()
