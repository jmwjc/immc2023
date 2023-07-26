# using StringAnalysis, CategoricalArrays, Languages, XLSX, DataFrames, ScikitLearn, StatsBase, Random
using MLJ, MLJText, StringAnalysis, CategoricalArrays, LinearAlgebra
import TextAnalysis: NaiveBayesClassifier

include("import.jl")

df = import_xlsx("Appendix IV.xlsx","Sheet2")

asin = levels(categorical(df[!,"asin"]))
rating = df[!,"overall"]
reviewText = df[!,"reviewText"]
# rg = r"don't|didn't|doesn't|wasn't|haven't|wouldn't|only|not|bad|wrong|disappoint|expensive|terrible|lack|stop|junk|no\sresponse|\?"
rg = r"good|pretty|better|don't|didn't|doesn't|wasn't|haven't|wouldn't|only|not|bad|wrong|disappoint|expensive|terrible|lack|stop|junk|no\sresponse|\?"

sd = StringAnalysis.AbstractDocument[]
sd_low = StringAnalysis.AbstractDocument[]

# for t in reviewText
#     s = NGramDocument(lowercase(t))
#     push!(sd,s)
# end

for (r,a) in zip(reviewText,rating)
    t = " "
    for w in eachmatch(rg,lowercase(r))
        t *= w.match*" "
    end
    s = NGramDocument(t)
    a ≤ 3 ? push!(sd_low,s) : nothing
    push!(sd,s)
end

crps = Corpus(sd)
crps_low = Corpus(sd_low)
update_lexicon!(crps)
update_lexicon!(crps_low)
# prepare!(crps, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords|stem_words)
ngram_docs = ngrams.(crps)
ngram_docs_low = ngrams.(crps_low)

train, test = partition(eachindex(reviewText), 0.8, shuffle=true)

tfidf_transformer = TfidfTransformer()
count_transformer = CountTransformer()
model = @load MultinomialNBClassifier pkg="NaiveBayes"
pipeline = count_transformer |> model
mach = machine(pipeline, ngram_docs, df[:,"overall"])
MLJ.fit!(mach,rows=train)

rating_predict = Int.(unwrap.(predict_mode(mach,rows=test)))

error = norm(rating[test] .- rating_predict)/norm(rating[test])
accuracy = sum(rating[test] .== rating_predict)/length(test)
println(rating_predict)
println("Accuracy: $accuracy")
println("Error: $error")
println(min(rating_predict...))