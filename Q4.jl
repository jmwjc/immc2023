using TextAnalysis, Distances

function is_automated_review(review_text::AbstractString, existing_reviews::Vector{T}; similarity_threshold::Float64=0.8, ngram_range::Tuple{Int,Int}=(1,1)) where T<:AbstractString
    # Tokenize the review text and existing reviews
    review_tokens = TokenDocument(review_text)
    existing_tokens = [TokenDocument(existing_review) for existing_review in existing_reviews]
    review_tokens = Corpus([review_tokens])
    existing_tokens = Corpus(existing_tokens)
    update_lexicon!(review_tokens)
    update_lexicon!(existing_tokens)
    
    # Create a document-term matrix for the existing reviews
    # existing_dtm = DocumentTermMatrix(crps, ngram_range=ngram_range)
    existing_dtm = DocumentTermMatrix(existing_tokens)
    
    # Create a document-term matrix for the current review
    # review_dtm = DocumentTermMatrix([review_tokens], ngram_range=ngram_range)
    review_dtm = DocumentTermMatrix(review_tokens)

    # normalize!(existing_dtm)
    # normalize!(review_dtm)

    similarity = Distances.cosine(existing_dtm, review_dtm)

    # Compute the cosine similarity between the current review and the existing reviews
    println(similarity)
    # similarities = [cosine_similarities(review_dtm, existing_dtm)[1, i] for i in 1:size(existing_dtm)[1]]
    
    # Check if the maximum similarity is greater than the threshold
    # return maximum(similarities) > similarity_threshold
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