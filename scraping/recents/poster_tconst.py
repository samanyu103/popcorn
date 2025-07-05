import requests
import json
import sys
import os

API_KEY = '9e0dfc62'
OUTPUT_FILE = 'posters.jsonl'

def fetch_movie_by_tconst(tconst):
    url = f"http://www.omdbapi.com/?apikey={API_KEY}&i={tconst}"
    response = requests.get(url)
    data = response.json()

    if data.get("Response") != "True":
        print(f"❌ Movie not found for tconst: {tconst}")
        return

    imdb_rating = float(data["imdbRating"]) if data["imdbRating"] != "N/A" else None
    num_votes = int(data["imdbVotes"].replace(",", "")) if data["imdbVotes"] != "N/A" else None
    poster_url = data["Poster"] if data["Poster"] != "N/A" else None
    year = int(data["Year"].split("–")[0]) if "Year" in data and data["Year"] != "N/A" else None

    movie_info = {
        "tconst": tconst,
        "year": year,
        "name": data.get("Title"),
        "imdb_rating": imdb_rating,
        "numVotes": num_votes,
        "recent": True,
        "poster_url": poster_url
    }

    # Append to posters.jsonl
    with open(OUTPUT_FILE, 'a', encoding='utf-8') as f:
        f.write(json.dumps(movie_info) + '\n')

    print(f"✅ Appended to {OUTPUT_FILE}: {movie_info['name']}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python poster_tconst.py <tconst>")
    else:
        fetch_movie_by_tconst(sys.argv[1])
