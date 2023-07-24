

    M = DocumentTermMatrix{Float32}(crps, collect(keys(crps.lexicon)));
    # stats: :count (term count), :tf (term frequency), :tfidf (default, term frequency-inverse document frequency) and :bm25 (Okapi BM25)
    lm = LSAModel(M, k=3, stats=:tf)
    U = lm.Uᵀ'
    case = 1
    index = sortperm(U[:,case])
    # words = collect(keys(lm.vocab_hash))
    # count = collect(values(lm.vocab_hash))
    words = collect(keys(crps.lexicon))
    count = collect(values(crps.lexicon))
    println(words[index])
    println(count[index])

    # println(crps.lexicon)
    # l = lsa(crps)
    # ngrams(crps)
    # println(lsa(crps))
    # println(dft)
# end


# wordcount = Dict{String,Int}()

# for r in dft[!,"reviewText"]
#     sd = StringDocument(lowercase(r))
#     prepare!(sd, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords|strip_numbers|strip_html_tags|strip_punctuation|strip_articles|strip_prepositions|strip_pronouns)
#     # stem!(sd)
#     for (w,c) in ngrams(sd)
#         haskey(wordcount,w) ? wordcount[w] += c : wordcount[w] = c
#     end
# end