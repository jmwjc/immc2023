using TextAnalysis, CategoricalArrays

include("import.jl")

df = import_xlsx("Appendix III.xlsx","Sheet2")

asin = levels(categorical(df[!,"asin"]))

for a in asin[1:1]
    dft = filter(:asin=> x-> x == a, df)
    sds = TextAnalysis.StringDocument{String}[]
    for r in df[!,"reviewText"]
        sd = StringDocument(lowercase(r))
        prepare!(sd, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords)
        prepare!(sd, strip_numbers|strip_html_tags|strip_non_letters)
        prepare!(sd, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords)
        push!(sds,sd)
    end
    crps = Corpus(sds)
    println(lsa(crps))
    # println(dft)
end