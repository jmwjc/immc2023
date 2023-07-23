using StringAnalysis, CategoricalArrays, Languages, XLSX

include("import.jl")

df = import_xlsx("Appendix III.xlsx","Sheet2")

asin = levels(categorical(df[!,"asin"]))

# for a in asin[1:1]
a = asin[1]
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
        push!(sd,NGramDocument(lowercase(t)))
    end
    crps = Corpus(sd)
    # prepare!(crps, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords|stem_words)
    prepare!(crps, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords)
    # println(dft[:,"reviewText"][1])
    # println(text(crps.documents[1]))
    update_lexicon!(crps)

    rstrip(word,['s'])