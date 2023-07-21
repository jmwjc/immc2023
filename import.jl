using DataFrames, XLSX, JSON, Dates

df = DataFrame(
    reviewerID = String[],
    asin = String[],
    reviewerName = String[],
    helpful = Tuple{Int,Int}[],
    reviewText = String[],
    overall = Float64[],
    summary = String[],
    unixReviewTime = Int[],
    reviewTime = Date[]
)
XLSX.openxlsx("Appendix I.xlsx", enable_cache=false) do f
    sheet = f["Sheet2"]
    for r in XLSX.eachrow(sheet)
        j = JSON.parse(r[1])
        reviewerID = j["reviewerID"]
        asin = j["asin"]
        reviewerName = haskey(j,"reviewerName") ? j["reviewerName"] : missing
        helpful = Tuple(s for s in j["helpful"])
        reviewText = j["reviewText"]
        overall = j["overall"]
        summary = j["summary"]
        unixReviewTime = j["unixReviewTime"]
        m,d,y = split(j["reviewTime"],' ')
        d = strip(d,[','])
        reviewTime = Date(y*m*d,dateformat"yyyymmdd")
        push!(df, (reviewerID,asin,reviewerName,helpful,reviewText,overall,summary,unixReviewTime,reviewTime), promote=true)
    end
end
