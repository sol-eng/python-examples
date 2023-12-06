from dotenv import load_dotenv
load_dotenv()
import dash
import os
import pandas as pd
import plotly.express as px
import requests as req

from dash import dcc, html
from dash.dependencies import Input, Output

app = dash.Dash(__name__)

locations = pd.read_csv("https://colorado.rstudio.com/rsc/bike_station_info/data.csv")
location_options = [
    {"label": locations["name"][l], "value": locations["station_id"][l]}
    for l in locations.index
]
mapbox = os.getenv("MAPBOX_API_KEY")

app.layout = html.Div(
    [
        html.Div(
            [
                html.Div(
                    [
                        html.Img(
                            src="https://d33wubrfki0l68.cloudfront.net/1ac3f0e3753f18c7e2a8893957d1841fba1e3d08/48a33/wp-content/uploads/2018/10/rstudio-logo-flat.png",
                            style={"height": "60px", "width": "auto"},
                        )
                    ],
                    className="one-third column",
                ),
                html.Div(
                    [
                        html.Div(
                            [
                                html.H3(
                                    "Capitol Bikeshare",
                                    style={"margin-bottom": "0px"},
                                ),
                                html.H5(
                                    "Availability Forecast", style={"margin-top": "0px"}
                                ),
                            ]
                        )
                    ],
                    className="one-half column",
                    id="title",
                ),
                html.Div(
                    [
                        html.A(
                            html.Button("View Code", id="learn-more-button"),
                            href="https://github.com/sol-eng/python-examples",
                        )
                    ],
                    className="one-third column",
                    id="button",
                ),
            ],
            id="header",
            className="row flex-display",
            style={"margin-bottom": "25px"},
        ),
        html.Div(
            [
                html.Div(
                    [
                        html.Div(
                            [
                                html.P("Select Location:"),
                                dcc.Dropdown(
                                    id="location", options=location_options, value=1
                                ),
                            ],
                            style={"margin-top": "10"},
                        ),
                    ],
                    className="row",
                ),
                html.Div(
                    [
                        html.Div([dcc.Graph(id="bike-forecast")]),
                        html.Div([dcc.Graph(id="bike-map")]),
                    ]
                ),
            ],
            className="row",
        ),
    ]
)


@app.callback(Output("bike-forecast", "figure"), [Input("location", "value")])
def update_forecast_graph(value):
    r = req.get(
        "https://colorado.rstudio.com/rsc/bike_predict_api/pred",
        params={"station_id": value},
    )
    prediction = pd.DataFrame.from_dict(r.json())
    fig = px.line(prediction, x="times", y="pred")
    fig.update_layout(
        xaxis_title="Day and Time",
        yaxis_title="Predicted Num of Bikes Available",
    )
    return fig


@app.callback(Output("bike-map", "figure"), [Input("location", "value")])
def update_bike_graph(value):
    this_station = locations[locations["station_id"] == value]
    df = pd.DataFrame.from_dict(
        {"lat": this_station["lat"], "lon": this_station["lon"], "size": 10}
    )
    px.set_mapbox_access_token(mapbox)
    fig = px.scatter_mapbox(df, lat="lat", lon="lon", size="size")
    fig.update_layout(mapbox_style="open-street-map", mapbox=dict(zoom=13))
    return fig


if __name__ == "__main__":
    app.run_server(debug=True)
