from flask import Flask, render_template, jsonify

app = Flask(__name__)


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/api/hello", methods=["GET"])
def hello():
    return jsonify({"message": "right back at ya!"})
