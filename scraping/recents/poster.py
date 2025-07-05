import pandas as pd
import requests
import json
import time

API_KEY = '9e0dfc62'
input_csv = 'recent_movies.csv'
output_jsonl = 'posters.jsonl'

# Load movie titles from CSV
df = pd.read_csv(input_csv, header=None, names=['title'])

with open(output_jsonl, 'w', encoding='utf-8') as outfile:
    for title in df['title']:
        title = title.strip()
        print(f"Fetching: {title}")
        url = f"http://www.omdbapi.com/?apikey={API_KEY}&t={requests.utils.quote(title)}"

        try:
            response = requests.get(url)
            data = response.json()

            if data.get("Response") == "True" and data.get("imdbID"):
                imdb_rating = float(data["imdbRating"]) if data["imdbRating"] != "N/A" else None
                num_votes = int(data["imdbVotes"].replace(",", "")) if data["imdbVotes"] != "N/A" else None

                json_obj = {
                    "tconst": data["imdbID"],
                    "year": int(data["Year"].split("–")[0]) if "Year" in data else None,
                    "name": data["Title"],
                    "imdb_rating": imdb_rating,
                    "numVotes": num_votes,
                    "recent": True,
                    "poster_url": data["Poster"] if data["Poster"] != "N/A" else None
                }

                outfile.write(json.dumps(json_obj) + '\n')
            else:
                print(f"❌ Not found: {title}")
        except Exception as e:
            print(f"⚠️ Error fetching {title}: {e}")
        time.sleep(1)  # avoid rate limiting
