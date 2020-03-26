import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output
import pandas as pd
import plotly.express as px
import requests as req

app = dash.Dash(__name__)

locations = pd.read_csv("https://colorado.rstudio.com/rsc/bike_station_info/data.csv")
location_options = [{'label': locations['name'][l], 'value': locations['station_id'][l]} for l in locations.index]
mapbox = "pk.eyJ1IjoibG9wcHNlYW4iLCJhIjoiY2s4OTFwaDB2MDJicDNkcXh2bm5oOWhwZSJ9.eLH6Sm3rovtXQVOy6kCXiw"

app.layout = html.Div(
    html.Div([
        html.Div([
            html.H1(children='Capitol Bikeshare Forecast')
        ], className = "rStudioHeader"),

        html.Div(
            [
                html.Div(
                    [
                        html.P('Select Location:'),
                        dcc.Dropdown(
                                id = 'location',
                                options = location_options,
                                value = 1
                        ),
                    ], style={'margin-top': '10'}
                ),
            ], className="row"
        ),

        html.Div([
            html.Div([
                dcc.Graph(
                    id='bike-forecast'
                )
            ]),
            html.Div([
                dcc.Graph(
                    id='bike-map'
                )
            ]),
        ])
    ], className = "row")
)

@app.callback(
    Output("bike-forecast","figure"),
    [Input("location", "value")]
)
def update_forecast_graph(value):
    r = req.get("https://colorado.rstudio.com/rsc/bike_predict_api/pred",
        params = {"station_id":value}
    )
    prediction = pd.DataFrame.from_dict(r.json())
    return px.line(prediction, x = "times", y = "pred")

@app.callback(
    Output("bike-map","figure"),
    [Input("location", "value")]
)
def update_bike_graph(value):
    this_station = locations[locations['station_id']==value]
    df = pd.DataFrame.from_dict({
        "lat" : this_station["lat"],
        "lon" : this_station["lon"],
        "size": 10
    })
    px.set_mapbox_access_token(mapbox)
    fig = px.scatter_mapbox(df, lat = "lat", lon = "lon", size ="size")
    fig.update_layout(mapbox_style="open-street-map",
                      mapbox=dict(zoom=13)
                    )
    return fig

if __name__ == "__main__":
    app.run_server(debug=True)