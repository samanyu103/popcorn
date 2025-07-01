import pandas as pd
import requests
import time
import json
from tqdm import tqdm

# N = 100
API_KEY = '9e0dfc62'  # Replace with your OMDb API key

# Load and sort the TSV file
df = pd.read_csv('numVotes.tsv', sep='\t')
topN = df.sort_values(by='numVotes', ascending=False)

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
output_file = 'posters.jsonl'

start_time = time.time()

# Iterate with tqdm
for _, row in tqdm(topN.iterrows(), total=len(topN), desc="Fetching posters"):
    tconst = row['tconst']
    name = row['primaryTitle']
    rating = row['averageRating']
    start_year = row['startYear']
    numVotes = row['numVotes']
    poster_url = get_poster_url(tconst, API_KEY)

    result = {
        'tconst': tconst,
        'name': name,
        'year': int(start_year),
        'imdb_rating': float(rating),
        'poster_url': poster_url,
        'numVotes': numVotes,
    }

    results.append(result)

    # Write partial results to file as you go
    # with open(output_file, 'w', encoding='utf-8') as f:
    #     json.dump(results, f, ensure_ascii=False, indent=2)
    with open(output_file, 'a', encoding='utf-8') as f:
        f.write(json.dumps(result, ensure_ascii=False) + '\n')

end_time = time.time()

# print(f"✅ Incrementally saved top {N} movies with posters to {output_file}")
print(f"⏱️ Time taken: {end_time - start_time:.2f} seconds")