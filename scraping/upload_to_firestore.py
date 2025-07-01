# import json
# import time
# import firebase_admin
# from firebase_admin import credentials, firestore
# from tqdm import tqdm

# # Load service account key
# cred = credentials.Certificate("popcorn-a42fa-firebase-adminsdk-fbsvc-6df305ad4b.json")
# firebase_admin.initialize_app(cred)

# # Get Firestore client
# db = firestore.client()

# start_time = time.time()  # ⏱️ Start timing

# # First pass: count lines (for tqdm total)
# with open('posters.jsonl', 'r', encoding='utf-8') as f:
#     total_lines = sum(1 for _ in f)

# # Second pass: read and upload with progress bar
# with open('posters.jsonl', 'r', encoding='utf-8') as f, tqdm(total=total_lines, desc="Uploading movies to Firestore") as pbar:
#     for line in f:
#         movie = json.loads(line)
#         tconst = movie['tconst']
#         doc_ref = db.collection('movies').document(tconst)
#         doc_ref.set({
#             'tconst': tconst,
#             'name': movie['name'],
#             'year': movie['year'],
#             'imdb_rating': movie['imdb_rating'],
#             'poster_url': movie['poster_url'],
#             'numVotes': movie['numVotes'],
#         })
#         pbar.update(1)

# end_time = time.time()  # ⏱️ End timing

# print("✅ All movies uploaded to Firestore!")
# print(f"⏱️ Time taken: {end_time - start_time:.2f} seconds")




import json
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate("popcorn-a42fa-firebase-adminsdk-fbsvc-6df305ad4b.json")
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

