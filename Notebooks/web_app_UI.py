import streamlit as st

from uszipcode import SearchEngine
import pandas as pd
import seaborn as sns
from scipy import stats
import numpy as np
import matplotlib.pyplot as plt
import warnings
from scipy.stats import mstats, pearsonr
import sqlite3
from fuzzywuzzy import process, fuzz
import functools



from sklearn.impute import KNNImputer

warnings.filterwarnings('ignore')

connection = sqlite3.connect(r'W:\Personal Projects\UCPP\Notebooks\Scraping\UCPP_test.db')

#connection = sqlite3.connect(r'Scraping\UCPP_test.db')

cursor = connection.cursor()

table_name = 'used_cars'
query = f"SELECT * FROM {table_name}"

df = pd.read_sql_query(query, connection)

st.title("Used Cars Regional Frequency Dashboard")

# user inputs with dynamic filtering

# Replace None/NaN values with a placeholder (like 'Unknown' or '') for sorting
df['Manufacturer'] = df['Manufacturer'].fillna('')
df['Model Name'] = df['Model Name'].fillna('')
df['State Name'] = df['State Name'].fillna('')
df['City Name'] = df['City Name'].fillna('')

# User inputs with dynamic filtering
selected_manufacturer = st.selectbox('Select Manufacturer', ['All'] + sorted(df['Manufacturer'].unique().tolist()))

if selected_manufacturer != 'All':
    filtered_df = df[df['Manufacturer'] == selected_manufacturer]
else:
    filtered_df = df

selected_model = st.selectbox('Select Model', ['All'] + sorted(filtered_df['Model Name'].unique().tolist()))

if selected_model != 'All':
    filtered_df = filtered_df[filtered_df['Model Name'] == selected_model]

selected_state = st.selectbox('Select State', ['All'] + sorted(filtered_df['State Name'].unique().tolist()))

if selected_state != 'All':
    filtered_df = filtered_df[filtered_df['State Name'] == selected_state]

selected_city = st.selectbox('Select City', ['All'] + sorted(filtered_df['City Name'].unique().tolist()))

if selected_city != 'All':
    filtered_df = filtered_df[filtered_df['City Name'] == selected_city]

# Convert 'Date' column to datetime if not already done
df['Date'] = pd.to_datetime(df['Date'], errors='coerce')

selected_year = st.selectbox('Select Year', ['All'] + sorted(filtered_df['Date'].dt.year.dropna().unique().tolist()))

if selected_year != 'All':
    filtered_df = filtered_df[filtered_df['Date'].dt.year == int(selected_year)]

# Display the filtered data
st.subheader(f"Frequency of Listings")
if not filtered_df.empty:
    frequency_data = filtered_df.groupby('City Name').size().reset_index(name='Frequency')
    st.bar_chart(frequency_data.set_index('City Name')['Frequency'])
else:
    st.write("No data available for the selected criteria.")
