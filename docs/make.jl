using Documenter, CreditMetrics

makedocs(sitename="CreditMetrics.jl",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
    ),
    modules = [CreditMetrics],
    pages = ["Home" => "index.md", "Reference" => "reference.md"]
)

deploydocs(
    repo = "github.com/kasperrisager/CreditMetrics.jl.git",
)
