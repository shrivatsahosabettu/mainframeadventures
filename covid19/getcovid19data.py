#!/usr/bin/python3

import sys
import requests


sep = ','
linecount = 1
result = ''

# Download COVID-19 CSV data from https://data.europa.eu/euodp/en/data/dataset/covid-19-coronavirus-data
url = 'https://opendata.ecdc.europa.eu/covid19/casedistribution/csv'
covidcsv = requests.get(url, allow_redirects=True)
open('covidcsv', 'wb').write(covidcsv.content)


with open('covidcsv') as f:
	lines = f.readlines()

for line in lines:
	if linecount == 1: # skip 1st line, because it's the header's names
		linecount = linecount + 1
	else:
		# dateRep,day,month,year,cases,deaths,countriesAndTerritories,geoId,countryterritoryCode,
		# popData2019,continentExp,Cumulative_number_for_14_days_of_COVID-19_cases_per_100000
		parts  = line.split(sep)
		day    = parts[1]
		month  = parts[2]
		year   = parts[3]
		cases  = parts[4]
		deaths = parts[5]
		cat    = parts[6].replace('_', ' ') # countriesAndTerritories. Some contain underscores, that we replace for spaces
		geoid  = parts[7]
		ctc    = parts[8] # countryterritoryCode

		if len(ctc) > 0:
			# Data contain Cases_on_an_international_conveyance_Japan,
			# but we are not interested on it. Hence, filter it out.

			if len(ctc) < 3:
				if cat.startswith('"'):
					# "Bonaire, Saint Eustatius and Saba" contains commas in the country name.
					# We need to reformat the name, as it's split into 2 different parts
					fullname = parts[6].replace('"', '') + ',' + parts[7].replace('"', '')
					result = year + month.zfill(2) + day.zfill(2) + cases.zfill(8) + deaths.zfill(8) + parts[9] + fullname.ljust(40)
			else:
				if ctc == 'CNG1925':
					# Convert Taiwan country code to TWN
					# Because it's easier for us later on MVS
					ctc = 'TWN'

				result = year + month.zfill(2) + day.zfill(2) + cases.zfill(8) + deaths.zfill(8) + ctc + cat.ljust(40)

			print(result)
