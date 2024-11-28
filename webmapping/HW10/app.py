import pandas as pd
import dash
from dash import dcc, html, dash_table
from dash.dependencies import Input, Output
import plotly.express as px


df = pd.read_csv('C:\\Users\\miiin\\miinakova\\webmapping\\HW10\\service_311.csv', encoding='ISO-8859-1')


app = dash.Dash()


app.layout = html.Div([
    html.Div(children='Hello World', style={'color': 'red'}), 
    dash_table.DataTable(
        data=df.to_dict('records'),
        page_size=10,
        id='data_table'
    ),
    dcc.Graph(
        figure=px.histogram(df, x='weekday', barmode='relative', histfunc='count', color='reason'),
        id='graph_his'
    ),
    dcc.RadioItems(
        options=[
            {'label': 'Daytime', 'value': 'daytime'},
            {'label': 'Nighttime', 'value': 'nighttime'},
            {'label': 'All', 'value': 'All'}
        ],
        value='All',
        id='radio_button'
    )
])

# Callback
@app.callback(
    [Output('graph_his', 'figure'), Output('data_table', 'data')],
    [Input('radio_button', 'value')]
)
def update_graph_and_table(time):
    if time == "All":
        filter_df = df
    else:
        filter_df = df[df['time_of_day'] == time]

    fig = px.histogram(filter_df, x='weekday', barmode='relative', histfunc='count', color='reason')
    table_data = filter_df.to_dict('records')

    return fig, table_data


if __name__ == '__main__':
    app.run_server(debug=True)