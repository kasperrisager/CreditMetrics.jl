using Documenter, CreditMetrics

makedocs(sitename="CreditMetrics.jl",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
    ),
    modules = [CreditMetrics]
)
