"""
    OPENINGS_URL::String
URL for accessing the public data for job opening advertisements in JSON format from EconJobMarket.
"""
const OPENINGS_URL = "https://backend.econjobmarket.org/data/zz_public/json/Ads"
"""
    CATEGORIES_URL::String
URL for accessing the public data for job opening categories in JSON format from EconJobMarket.
"""
const CATEGORIES_URL = "https://backend.econjobmarket.org/data/zz_public/json/Categories"
"""
    CATEGORIES::Vector{Symbol}
Job opening advertisements categories.
"""
const CATEGORIES = JSON3.read(read(joinpath(dirname(@__DIR__), "data", "Categories.json"))) |>
    (obj -> Symbol.(getproperty.(obj, :name)))
"""
    categories_indicator(obj::AbstractString)::BitVector
Given a string, it provides indicators for whether the job ad listed each opening category.

# Example
```julia-repl
julia> EconJobMarket.categories_indicator("2,3")
```
"""
function categories_indicator(obj::AbstractString)
    output = BitVector(undef, 34)
    for elem in eachmatch(r"\d+", obj)
        output[parse(Int, elem.match)] = true
    end
    output
end
"""
    parse_opening(node)::NamedTuple
For each opening, it parses the information.
"""
function parse_opening(node)
    posid = isnothing(node.posid) ? missing : parse(Int, node.posid)
    oid = isnothing(node.oid) ? missing : parse(Int, node.oid)
    adtitle = isnothing(node.adtitle) ? missing : node.adtitle
    position_type_id = isnothing(node.position_type) ? missing : node.position_type_id
    position_type = isnothing(node.position_type) ? missing : node.position_type
    adtext =
        reduce((x, y) -> "$x $y",
               nodeText(node) for node in eachmatch(Selector("body"),
                                                    parsehtml(node.adtitle).root))
    startdate = isnothing(node.startdate) ? missing : Date(node.startdate)
    enddate = isnothing(node.enddate) ? missing : Date(node.enddate)
    country_code = isnothing(node.country_code) ? missing : node.country_code
    position_country = isnothing(node.position_country) ? missing : node.position_country
    department = isnothing(node.department) ? missing : node.department
    shortname = isnothing(node.shortname) ? missing : node.shortname
    address = isnothing(node.address) ? missing : node.address
    longitude = isnothing(node.longitude) ? missing : parse(Float64, node.longitude)
    latitude = isnothing(node.latitude) ? missing : parse(Float64, node.latitude)
    name = isnothing(node.name) ? missing : node.shortname
    cats = isnothing(node.categories) ? missing : categories_indicator(node.categories)
    (; zip(Tuple(Symbol(clean_name(elem)) for elem in propertynames(node)
                 if clean_name(elem) ≠ "categories"),
           (posid, oid, adtitle, position_type_id, position_type,
            adtext, startdate, enddate, country_code, position_country,
            department, shortname, address, longitude, latitude, name,
            cats...))...)
end
"""
    fetch_ads(filepath::AbstractString; delim::Union{Char,AbstractString} = \'\\t\')
Writes a text file with the latest job opening advertisements from EJM.

# Example
```jldoctest
julia> fetch_ads("ads.tsv")
"ads.tsv"
julia> data = CSV.read("ads.tsv");
```
"""
fetch_ads(filepath::AbstractString; delim::Union{Char,AbstractString} = '\t') =
    OPENINGS_URL |>
    HTTP.get |>
    (response -> response.body) |>
    String |>
    JSON3.read |>
    (data -> CSV.write(filepath,
                       columntable(parse_opening(node) for node ∈ data),
                       delim = delim))
