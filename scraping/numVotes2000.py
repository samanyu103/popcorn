import pandas as pd

# Load the TSV file
df = pd.read_csv('movies_with_ratings.tsv', sep='\t')

# Filter rows with a reasonable number of votes (e.g., at least 1000 votes)
df['startYear'] = pd.to_numeric(df['startYear'], errors='coerce').astype('Int64')

filtered_df = df[(df['numVotes'] >= 2000) & (df['averageRating'] >= 6)]

# Sort by numVotes in decreasing order
sorted_df = filtered_df.sort_values(by='numVotes', ascending=False)

# Keep selected columns
sorted_df = sorted_df[['tconst', 'startYear', 'primaryTitle', 'averageRating', 'numVotes']]

# Save to TSV
sorted_df.to_csv('numvotes.tsv', sep='\t', index=False)

# Print number of movies after filtering
print("Number of movies with at least 2000 votes:", len(sorted_df))
