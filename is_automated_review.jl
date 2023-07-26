using TextAnalysis, LinearAlgebra

function is_automated_review(review_text::String,existing_reviews::Vector{String}; similarity_threshold::Float64=0.8)
    # Tokenize the review text and existing reviews
    review_tokens = TokenDocument(lowercase(review_text))
    existing_tokens = [TokenDocument(lowercase(existing_review)) for existing_review in existing_reviews]
    review_tokens = Corpus([review_tokens])
    existing_tokens = Corpus(existing_tokens)
    update_lexicon!(review_tokens)
    update_lexicon!(existing_tokens)
    
    # Create a document-term matrix for the existing reviews
    existing_dtm = DocumentTermMatrix(existing_tokens)
    
    # Create a document-term matrix for the current review
    review_dtm = DocumentTermMatrix(review_tokens)

    v1 = Int[]
    for (i,term) in enumerate(review_dtm.terms)
        if term ∈ existing_dtm.terms
            push!(v1,review_dtm.dtm[1,i])
        end
    end
    for i in 1:length(existing_reviews)
        v2 = Int[]
        for term in review_dtm.terms
            if term ∈ existing_dtm.terms
                j = findfirst(x->x==term,existing_dtm.terms)
                push!(v2,existing_dtm.dtm[i,j])
            end
        end
        if v1'*v2/norm(v1)/norm(v2) > similarity_threshold
            return true
        end
    end
    return false
end