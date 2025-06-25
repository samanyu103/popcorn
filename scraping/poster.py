import pandas as pd
import requests
import time
import json

N = 100
API_KEY = '9e0dfc62'  # Replace with your OMDb API key

# Load and sort the TSV file
df = pd.read_csv('numVotes.tsv', sep='\t')
topN = df.sort_values(by='numVotes', ascending=False).head(N)

# Function to fetch poster URL using OMDb
def get_poster_url(tconst: str, api_key: str) -> str | None:
    url = 'http://www.omdbapi.com/'
    params = {'apikey': api_key, 'i': tconst}
    try:
        response = requests.get(url, params=params, timeout=5)
        response.raise_for_status()
        data = response.json()
        poster_url = data.get('Poster')
        return poster_url if poster_url and poster_url != 'N/A' else None
    except Exception as e:
        print(f"Error for {tconst}: {e}")
        return None

results = []

start_time = time.time()

# Iterate over top movies and collect data
for _, row in topN.iterrows():
    tconst = row['tconst']
    name = row['primaryTitle']
    rating = row['averageRating']
    start_year = row['startYear']
    poster_url = get_poster_url(tconst, API_KEY)

    results.append({
        'tconst': tconst,
        'name': name,
        'year': int(start_year),
        'imdb_rating': float(rating),
        'poster_url': poster_url
    })
    # Optional: sleep to avoid rate limits
    # time.sleep(0.25)

end_time = time.time()

# Save to JSON
with open('top100_posters.json', 'w', encoding='utf-8') as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print(f"✅ Saved top {N} movies with posters to top100_posters.json")
print(f"⏱️ Time taken: {end_time - start_time:.2f} seconds")
