# using StringAnalysis, CategoricalArrays, Languages, XLSX, DataFrames, ScikitLearn, StatsBase, Random
using MLJ, MLJText, StringAnalysis, CategoricalArrays, LinearAlgebra
import TextAnalysis: NaiveBayesClassifier

include("import.jl")

df = import_xlsx("Appendix IV.xlsx","Sheet2")

asin = levels(categorical(df[!,"asin"]))
rating = df[!,"overall"]
reviewText = df[!,"reviewText"]
# rg = r"don't|didn't|doesn't|wasn't|haven't|wouldn't|only|not|bad|wrong|disappoint|expensive|terrible|lack|stop|junk|no\sresponse|\?"
# rg = r"good|pretty|better|don't|didn't|doesn't|wasn't|haven't|wouldn't|only|not|bad|wrong|disappoint|expensive|terrible|lack|stop|junk|no\sresponse|\?"

keywords = String[]
sd = StringAnalysis.AbstractDocument[]
sd_5 = StringAnalysis.AbstractDocument[]
sd_low = StringAnalysis.AbstractDocument[]

# for t in reviewText
#     s = NGramDocument(lowercase(t))
#     push!(sd,s)
# end

for (r,a) in zip(reviewText,rating)
    t = " "
    for w in eachmatch(r"[a-zA-Z]{3,}",r)
        t *= w.match*" "
    end
    s = StringDocument(lowercase(t))
    a ≤ 4 ? push!(sd_low,s) : push!(sd_5,s)
    push!(sd,s)
end
crps = Corpus(sd)
crps_5 = Corpus(sd_5)
crps_low = Corpus(sd_low)
prepare!(crps, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords|stem_words|strip_numbers|strip_html_tags|strip_single_chars|strip_frequent_terms)
prepare!(crps_5, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords|stem_words|strip_numbers|strip_html_tags|strip_single_chars|strip_frequent_terms)
prepare!(crps_low, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords|stem_words|strip_numbers|strip_html_tags|strip_single_chars|strip_frequent_terms)
update_lexicon!(crps)
update_lexicon!(crps_5)
update_lexicon!(crps_low)
lexicon_5 = crps_5.lexicon
lexicon_low = crps_low.lexicon
total_5 = sum(values(lexicon_5))
total_low = sum(values(lexicon_low))
tol = 1e-4
for (w,c) in lexicon_low
    if haskey(lexicon_5,w)
        Δ = c/total_low-lexicon_5[w]/total_5
    else
        Δ = c/total_low
    end
    if Δ ≥ tol
        println("$w: $c")
        push!(keywords,w)
    end
end
rg = keywords[1]
for k in keywords[2:end]
    global rg *= "|"*k
end
rg = Regex(rg)

# sd = StringAnalysis.AbstractDocument[]
# crps = Corpus(sd)
# update_lexicon!(crps)
ngram_docs = ngrams.(crps)
# ngram_docs_low = ngrams.(crps_low)

train, test = partition(eachindex(reviewText), 0.8, shuffle=true)

tfidf_transformer = TfidfTransformer()
count_transformer = CountTransformer()
model = @load MultinomialNBClassifier pkg="NaiveBayes"
# model = @load GaussianNBClassifier pkg="NaiveBayes"
# model = @load LinearRegressor pkg="MLJLinearModels"
pipeline = count_transformer |> model
mach = machine(pipeline, ngram_docs, df[:,"overall"])
MLJ.fit!(mach,rows=train)

rating_predict = Int.(unwrap.(predict_mode(mach,rows=test)))

error = norm(rating[test] .- rating_predict)/norm(rating[test])
accuracy = sum(rating[test] .== rating_predict)/length(test)
# println(rating_predict)
println("Accuracy: $accuracy")
println("Error: $error")
println(min(rating_predict...))