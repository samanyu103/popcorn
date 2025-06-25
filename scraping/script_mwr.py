import pandas as pd

# Load the title basics file
basics = pd.read_csv('title.basics.tsv', sep='\t', dtype=str, na_values='\\N')

# Filter for movies
movies = basics[basics['titleType'] == 'movie'].copy()

# Load the ratings file
ratings = pd.read_csv('title.ratings.tsv', sep='\t', dtype=str)

# Merge on tconst
merged = pd.merge(movies, ratings, on='tconst', how='inner')

# Optional: Keep only relevant columns
merged = merged[[
    'tconst', 'primaryTitle', 'originalTitle', 'startYear', 'runtimeMinutes', 'genres',
    'averageRating', 'numVotes'
]]

# Save to TSV
merged.to_csv('movies_with_ratings.tsv', sep='\t', index=False)

print(f"Saved {len(merged)} movies with ratings to 'movies_with_ratings.tsv'")
