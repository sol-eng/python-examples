# flask-restx Example

This example uses Flask to make a simple model available for others to use for
prediction. The example uses the `flask-restx` package to automatically generate
the documentation for the model API.

The script `train.py` creates the model object, and the script `predict.py`
creates the Flask API.

This example can be deployed to RStudio Connect using the `rsconnect-python`
package, specifically with `rsconnect deploy api -e predict:app .`.

