using Documenter, Weave, EconJobMarket
DocMeta.setdocmeta!(EconJobMarket, :DocTestSetup, :(using EconJobMarket), recursive = true)
for file ∈ readdir(joinpath(dirname(pathof(EconJobMarket)), "..", "docs", "jmd"))
    weave(joinpath(dirname(pathof(EconJobMarket)), "..", "docs", "jmd", file),
          out_path = joinpath(dirname(pathof(EconJobMarket)), "..", "docs", "src"),
          doctype = "github")
end
makedocs(format = Documenter.HTML(),
         modules = [EconJobMarket],
         sitename = "EconJobMarket.jl",
         pages = ["Introduction" => "index.md",
                  "API" => "api.md"]
    )
deploydocs(repo = "github.com/Nosferican/EconJobMarket.jl.git")
