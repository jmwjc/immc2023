using WordCloud

include("import.jl")

df = import_xlsx("Appendix I.xlsx","Sheet2")

wordcount = Dict{String,Int}()

for r in df[!,"reviewText"]
    for w in eachmatch(r"[a-zA-Z]+",r)
        m = w.match
        if length(m) == 1 && m ≠ "I" continue end
        if m ≠ "I" m = lowercase(m) end
        haskey(wordcount,m) ? wordcount[m] += 1 : wordcount[m] = 1
    end
end

wordcount_percent = Dict{String,Float64}()
totalwords = sum(values(wordcount))
for (word,count) in wordcount
    if count > 1000
        wordcount_percent[word] = count/totalwords*1e5
    end
end

wc = wordcloud(wordcount_percent) |> generate!
# wc = wordcloud(words,weights)
# generate!(wc)
# paint(wc,"wordcloud.svg")