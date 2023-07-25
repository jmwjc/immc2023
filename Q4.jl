using TextAnalysis

function is_automated_review(review_text::AbstractString, existing_reviews::Vector{AbstractString}; similarity_threshold::Float64=0.8, ngram_range::Tuple{Int,Int}=(1,1))
    # Tokenize the review text and existing reviews
    review_tokens = tokenize(review_text)
    existing_tokens = [tokenize(existing_review) for existing_review in existing_reviews]
    
    # Create a document-term matrix for the existing reviews
    existing_dtm = DocumentTermMatrix(existing_tokens, ngram_range=ngram_range)
    
    # Create a document-term matrix for the current review
    review_dtm = DocumentTermMatrix([review_tokens], ngram_range=ngram_range)
    
    # Compute the cosine similarity between the current review and the existing reviews
    similarities = [cosine_similarities(review_dtm, existing_dtm)[1, i] for i in 1:size(existing_dtm)[1]]
    
    # Check if the maximum similarity is greater than the threshold
    return maximum(similarities) > similarity_threshold
end
existing_reviews = [
    "Great product, I love it!",
    "Terrible service, would not recommend",
    "This is the best thing I've ever purchased"
]

review1 = "This is a great product, highly recommended!"
review2 = "This product is terrible, do not buy it"
review3 = "I love this product, it's the best thing ever"

is_automated_review(review1, existing_reviews) # returns false
is_automated_review(review2, existing_reviews) # returns false
is_automated_review(review3, existing_reviews) # returns true