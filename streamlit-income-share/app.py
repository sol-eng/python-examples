import os.path

import altair as alt
import pandas as pd
import streamlit as st

HERE = os.path.dirname(os.path.abspath(__file__))

st.title("Top 5%" " income share")
st.markdown("Share of income received by the richest 5%" " of the population.")
DATA = os.path.join(HERE, "data.csv")


@st.cache_data
def load_data(nrows):
    return pd.read_csv("./data.csv", nrows=nrows)


data_load_state = st.text("Loading data...")
data = load_data(10000)
data_load_state.text("")

countries = st.multiselect(
    "Countries",
    list(sorted({d for d in data["Entity"]})),
    default=["Australia", "China", "Germany", "Japan", "United States"],
)
earliest_year = data["Year"].min()
latest_year = data["Year"].max()
min_year, max_year = st.slider(
    "Year Range",
    min_value=int(earliest_year),
    max_value=int(latest_year),
    value=[int(earliest_year), int(latest_year)],
)
filtered_data = data[data["Entity"].isin(countries)]
filtered_data = filtered_data[filtered_data["Year"] >= min_year]
filtered_data = filtered_data[filtered_data["Year"] <= max_year]

chart = (
    alt.Chart(filtered_data)
    .mark_line()
    .encode(
        x=alt.X("Year", axis=alt.Axis(format="d")),
        y=alt.Y("Percent", axis=alt.Axis(format="~s")),
        color="Entity",
        strokeDash="Entity",
    )
)
st.altair_chart(chart, use_container_width=True)

if st.checkbox("Show raw data"):
    st.subheader("Raw data")
    st.write(filtered_data)

st.markdown("Source: <https://ourworldindata.org/grapher/top-5-income-share>")
