
using XLSX, CategoricalArrays

include("import.jl")
include("is_automated_review.jl")

df = import_xlsx("Appendix I.xlsx","Sheet2")

asin = levels(categorical(df[!,"asin"]))

# for i in 1:length(df[:,"asin"])
#     if ~is_automated_review(df[i,"reviewText"],df[1:end .!= i,"reviewText"], similarity_threshold = 0.9)
#         println("false")
#     end
# end
for a in asin[3:3]
    dft = filter(:asin=> x-> x == a, df)
    for i in 1:length(dft[:,"asin"])
        println(is_automated_review(df[i,"reviewText"],dft[1:end .!= i,"reviewText"], similarity_threshold = 0.8))
    end
end

    