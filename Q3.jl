using StringAnalysis, CategoricalArrays, Languages, XLSX, DataFrames, MLJ

include("import.jl")

df = import_xlsx("Appendix IV.xlsx","Sheet2")

asin = levels(categorical(df[!,"asin"]))
rating = levels(categorical(df[!,"overall"]))
asinrating = Dict{String,Vector{}}()

for a in asin
    dft = filter(:asin=> x-> x == a, df)
    sd = StringAnalysis.AbstractDocument[]
    for r in dft[:,"reviewText"]
        t = " "
        for w in eachmatch(r"[a-zA-Z]{3,}",r)
            t *= w.match*" "
        end
        s = StringDocument(lowercase(t))
        push!(sd,s)
    end
    # prepare!(sd, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords|stem_words)

f = CountVectorizer(strip_numbers=true, stop_words="english", min_ngram=1, max_ngram=2)
# f = BagOfWords(ngram_type=NGram(1), min_df=1, max_df=1.0)
X = fit_transform(f, sd)
y = rating

model = @load LogisticRegressor pkg=MLJLinearModels
lr = machine(model, X, y)
fit!(lr)

ŷ = predict(lr, X)
accuracy(ŷ, y)

mse = mean((ŷ - y)^2)
rmse = sqrt(mse)
end














    # M = DocumentTermMatrix{Float32}(crps, collect(keys(crps.lexicon)));
    # stats: :count (term count), :tf (term frequency), :tfidf (default, term frequency-inverse document frequency) and :bm25 (Okapi BM25)
    # lm = LSAModel(M, k=3, stats=:tf)
    # U = lm.Uᵀ'
    # case = 1
    # index = sortperm(U[:,case])
    # words = collect(keys(lm.vocab_hash))
    # count = collect(values(lm.vocab_hash))
    # words = collect(keys(crps.lexicon))
    # count = collect(values(crps.lexicon))
    # println(words[index])
    # println(count[index])

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