import sys
import firebase_admin
from firebase_admin import credentials, firestore

# 🔐 Initialize Firebase (only once)
cred = credentials.Certificate("../popcorn-5e82a-firebase-adminsdk-fbsvc-662d2c290e.json")
firebase_admin.initialize_app(cred)

# 🔥 Initialize Firestore
db = firestore.client()

# 🎯 Read tconst from command line
if len(sys.argv) != 2:
    print("Usage: python remove_tconst.py <tconst>")
    sys.exit(1)

tconst = sys.argv[1]
doc_ref = db.collection('movies').document(tconst)

# 📥 Get the document
doc = doc_ref.get()

if doc.exists:
    movie_name = doc.to_dict().get('name', '[Unknown Name]')
    doc_ref.delete()
    print(f"✅ Deleted '{movie_name}' (tconst: {tconst})")
else:
    print(f"❌ No movie found with tconst: {tconst}")
