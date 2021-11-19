# API documentation with flask-restx

This example uses Flask to make a simple model available for others to use for
prediction. The example uses the `flask-restx` package to automatically generate
the documentation for the model API.

The script `train.py` creates the model object, and the script `predict.py`
creates the Flask API.

## Setup

```
python train.py
```
## Deploy

```
rsconnect deploy api -e predict:app . -n <SERVER-NICKNAME>
```