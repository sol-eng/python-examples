import altair as alt
import pandas as pd
from shinywidgets import output_widget, render_widget
from shiny import App, reactive, ui

income_shares = pd.read_csv("data.csv")
countries = income_shares["Entity"].unique().tolist()

select_countries = {
    "default": ["Australia", "China", "Germany", "Japan", "United States"],
    "latam": ["Argentina", "Uruguay"],
    "apac": ["Australia", "China", "Singapore", "Japan", "Korea, South"],
    "emea": ["Mauritius", "France", "Italy", "Norway", "Spain"],
    "na": ["United States", "Canada"],
}

app_ui = ui.page_fluid(
    ui.panel_title("Top 5% Income Share"),
    ui.p("Share of income received by the richest 5% of the population"),
    ui.layout_sidebar(
        ui.panel_sidebar(
            ui.input_selectize(
                "countries",
                "Countries:",
                choices=countries,
                multiple=True,
                selected=select_countries["default"],
            ),
            ui.p("Regions:"),
            ui.TagList(
                ui.div(
                    {"class": "btn-group"},
                    ui.input_action_button("apac", "APAC"),
                    ui.input_action_button("emea", "EMEA"),
                    ui.input_action_button("latam", "LATAM"),
                    ui.input_action_button("na", "NA"),
                )
            ),
            ui.input_slider(
                "year_range",
                "Year Range:",
                min=1946,
                max=2015,
                value=(1946, 2015),
                sep="",
            ),
        ),
        ui.panel_main(
            output_widget("income_plot", width="800px"),
        ),
    ),
)


def server(input, output, session):
    @reactive.Calc
    def plot_data():
        df = income_shares.loc[
            (income_shares["Entity"].isin(input.countries()))
            & (income_shares["Year"] >= input.year_range()[0])
            & (income_shares["Year"] <= input.year_range()[1])
        ]
        return df

    @output
    @render_widget
    def income_plot():
        chart = (
            alt.Chart(plot_data())
            .mark_line()
            .encode(
                x=alt.X("Year", axis=alt.Axis(format="d")),
                y=alt.Y("Percent", axis=alt.Axis(format="~s")),
                color="Entity",
                strokeDash="Entity",
            )
        )
        return chart

    def make_button_listener(name):
        @reactive.Effect
        @reactive.event(input[name])
        def _():
            ui.update_selectize("countries", selected=select_countries[name])

    for name in select_countries.keys():
        make_button_listener(name)


app = App(app_ui, server)
if __name__ == "__main__":
    app.run()
