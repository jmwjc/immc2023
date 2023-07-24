using StringAnalysis, CategoricalArrays, Languages, XLSX, DataFrames

include("import.jl")

df = import_xlsx("Appendix III.xlsx","Sheet2")

asin = levels(categorical(df[!,"asin"]))
asinname = Dict{String,String}()
for a in asin
    # a = asin[2000]
    dft = filter(:asin=> x-> x == a, df)
    sd = StringAnalysis.AbstractDocument[]
    for r in dft[:,"reviewText"]
        t = " "
        for w in eachmatch(r"[a-zA-Z]+",r)
            t *= w.match*" "
        end
        # s = StringDocument(lowercase(t))
        # println(text(s))
        # println(stem!(s))  
        rstrip(t,['s'])
        push!(sd,NGramDocument(lowercase(t)))
    end
    crps = Corpus(sd)
    # prepare!(crps, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords|stem_words)
    prepare!(crps, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords)
    # println(dft[:,"reviewText"][1])
    # println(text(crps.documents[1]))
    update_lexicon!(crps)
    words = collect(keys(crps.lexicon))
    count = collect(values(crps.lexicon))
    c,p = findmax(count)
    word = words[p]
    asinname[a] = word
end

XLSX.openxlsx("./dfq.xlsx", mode="rw") do xf
    sheet = xf[1]
    sheet[1, :] = asinname.keys

end