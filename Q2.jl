using StringAnalysis, CategoricalArrays, Languages, XLSX, DataFrames

include("import.jl")

df = import_xlsx("Appendix IV.xlsx","Sheet2")

asin = levels(categorical(df[!,"asin"]))
asinname = Dict{String,String}()

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
    crps = Corpus(sd)
    prepare!(crps, strip_articles|strip_prepositions|strip_pronouns|strip_stopwords)
    update_lexicon!(crps)
    words = collect(keys(crps.lexicon))
    count = collect(values(crps.lexicon))
    index = sortperm(count,rev=true)
    words = words[index]
    count = count[index]
    n = 1
    i = 2
    asinname[a] = words[1]
    while n ≤ 3 || count[i] == count[1]
        asinname[a] *= ","*words[i]
        i += 1
        n += 1
    end
end

XLSX.openxlsx("./Q2IV.xlsx", mode="rw") do xf
    sheet = xf[1]
    sheet["A1"] = "asin"
    sheet["B1"] = "name"
    for (i,(a,w)) in enumerate(asinname)
        sheet["A"*string(i+1)] = a
        sheet["B"*string(i+1)] = w
    end
end