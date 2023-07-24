using WordCloud, TextAnalysis

include("import.jl")

df = import_xlsx("Appendix II.xlsx","Sheet2")
wordcount = Dict{String,Int}()

for r in df[!,"reviewText"]
    t = " "
    for w in eachmatch(r"[a-zA-Z]{3,}",r)
        t *= w.match*" "
    end
    sd = StringDocument(lowercase(t))
    prepare!(sd, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords|stem_words)
    for (w,c) in ngrams(sd)
        haskey(wordcount,w) ? wordcount[w] += c : wordcount[w] = c
    end
end
wordcount_percent = Dict{String,Float64}()
totalwords = sum(values(wordcount))
for (word,count) in wordcount
    if count > 1000
        wordcount_percent[word] = count/totalwords*1e5
    end
end
wc = wordcloud(
    wordcount_percent,outline = 4,
    mask=shape(box, 500 * 2, 400 * 2,cornerradius=10 * 2),
    colors = :Set1_5,
    angles = (-5, 5),
    fonts = "Tahoma",
    density=0.55,
    spacing = 3,
) |> generate!