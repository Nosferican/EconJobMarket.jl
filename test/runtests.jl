using Documenter, Test, Weave, EconJobMarket
for file ∈ readdir(joinpath(dirname(pathof(EconJobMarket)), "..", "docs", "jmd"))
      weave(joinpath(dirname(pathof(EconJobMarket)), "..", "docs", "jmd", file),
            out_path = joinpath(dirname(pathof(EconJobMarket)), "..", "docs", "src"),
            doctype = "github")
end
DocMeta.setdocmeta!(EconJobMarket, :DocTestSetup, :(using EconJobMarket), recursive = true)
makedocs(root = joinpath(dirname(@__DIR__), "docs"),
         format = Documenter.HTML(),
         modules = [EconJobMarket],
         sitename = "EconJobMarket.jl",
         pages = ["Introduction" => "index.md",
                  "API" => "api.md"]
    )
doctest(EconJobMarket)
@testset "Ads" begin
    data = joinpath(dirname(@__DIR__), "data", "ads.tsv") |>
        fetch_ads |>
        CSV.read;
    data = CSV.read(joinpath(dirname(@__DIR__), "data", "ads.tsv"));
    @test string(Tables.schema(data)) == "Tables.Schema:\n :posid             Int64                  \n :oid               Int64                  \n :adtitle           String                 \n :position_type_id  Int64                  \n :position_type     String                 \n :adtext            String                 \n :categories        Dates.Date             \n :startdate         Dates.Date             \n :enddate           Union{Missing, String} \n :country_code      Union{Missing, String} \n :position_country  String                 \n :department        String                 \n :shortname         Union{Missing, String} \n :address           Union{Missing, Float64}\n :longitude         Union{Missing, Float64}\n :latitude          String                 \n :name              Bool                   "
end
