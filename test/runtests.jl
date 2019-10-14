using Documenter, Test, Weave, EconJobMarket
const DOCSPATH = realpath(joinpath(dirname(pathof(EconJobMarket)), "..", "docs"))
joinpath(DOCSPATH, "src") |>
    (dir -> isdir(dir) || mkdir(dir))
foreach(rm, joinpath(DOCSPATH, "src", file) for file ∈ readdir(joinpath(DOCSPATH, "src")))
foreach(filepath -> weave(joinpath(DOCSPATH, "jmd", filepath),
                          out_path = joinpath(DOCSPATH, "src"),
                          doctype = "github"),
        readdir(joinpath(DOCSPATH, "jmd")))
DocMeta.setdocmeta!(EconJobMarket, :DocTestSetup, :(using EconJobMarket), recursive = true)
makedocs(root = DOCSPATH,
         format = Documenter.HTML(),
         modules = [EconJobMarket],
         sitename = "EconJobMarket.jl",
         pages = ["Introduction" => "index.md",
                  "API" => "api.md"])
doctest(EconJobMarket)
