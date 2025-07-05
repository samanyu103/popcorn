import json
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate("popcorn-5e82a-firebase-adminsdk-fbsvc-662d2c290e.json")

firebase_admin.initialize_app(cred)
db = firestore.client()

# Count total lines for progress bar
with open('posters.jsonl', 'r', encoding='utf-8') as f:
    total_lines = sum(1 for _ in f)

# Function to upload a single movie
def upload_movie(line: str) -> str:
    try:
        movie = json.loads(line)
        tconst = movie['tconst']
        doc_ref = db.collection('movies').document(tconst)
        doc_ref.set({
            'tconst': tconst,
            'name': movie['name'],
            'year': movie['year'],
            'imdb_rating': movie['imdb_rating'],
            'poster_url': movie['poster_url'],
            'numVotes': movie['numVotes'],
        })
        return tconst  # Success
    except Exception as e:
        return f"Error: {e}"

start_time = time.time()

# Use ThreadPoolExecutor for parallelism
with open('posters.jsonl', 'r', encoding='utf-8') as f, \
     ThreadPoolExecutor(max_workers=20) as executor, \
     tqdm(total=total_lines, desc="Uploading movies (parallel)") as pbar:

    # Submit all lines for parallel upload
    futures = [executor.submit(upload_movie, line) for line in f]

    for future in as_completed(futures):
        result = future.result()
        # Optional: log result if needed
        # print(result)
        pbar.update(1)

end_time = time.time()

print("✅ All movies uploaded to Firestore in parallel!")
print(f"⏱️ Time taken: {end_time - start_time:.2f} seconds")

