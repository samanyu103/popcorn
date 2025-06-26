import json
import time
import firebase_admin
from firebase_admin import credentials, firestore

# Load service account key
cred = credentials.Certificate("popcorn-a42fa-firebase-adminsdk-fbsvc-6df305ad4b.json")
firebase_admin.initialize_app(cred)

# Get Firestore client
db = firestore.client()

# Load your movie JSON file
with open('top100_posters.json', 'r', encoding='utf-8') as f:
    movies = json.load(f)

start_time = time.time()  # ⏱️ Start timing

# Upload to Firestore collection 'movies'
for movie in movies:
    tconst = movie['tconst']
    doc_ref = db.collection('movies').document(tconst)
    doc_ref.set({
        'tconst': tconst,
        'name': movie['name'],
        'year': movie['year'],
        'imdb_rating': movie['imdb_rating'],
        'poster_url': movie['poster_url']
    })

end_time = time.time()  # ⏱️ End timing

print("✅ All movies uploaded to Firestore!")
print(f"⏱️ Time taken: {end_time - start_time:.2f} seconds")
