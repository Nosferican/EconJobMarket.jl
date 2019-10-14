"""
    OPENINGS_URL::String
[URL](https://backend.econjobmarket.org/data/zz_public/json/Ads) for accessing the public data for job opening advertisements in JSON format from EconJobMarket.
"""
const OPENINGS_URL = "https://backend.econjobmarket.org/data/zz_public/json/Ads"
"""
    CATEGORIES_URL::String
[URL](https://backend.econjobmarket.org/data/zz_public/json/Categories) for accessing the public data for job opening categories in JSON format from EconJobMarket.
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
```jldoctest
julia> EconJobMarket.categories_indicator("2,3")
34-element BitArray{1}:
 0
 1
 1
 0
 0
 0
 0
 0
 0
 0
 ⋮
 0
 0
 0
 0
 0
 0
 0
 0
 0
```
"""
categories_indicator(obj::AbstractString) =
    1:34 .∈ Ref([ parse(Int, elem.match) for elem ∈ eachmatch(r"\d+", obj) ])
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
               nodeText(node) for node ∈ eachmatch(Selector("body"),
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
    (; zip(Tuple(Symbol(clean_name(elem)) for elem ∈ propertynames(node)
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
julia> data = joinpath(dirname(@__DIR__), "data", "ads.tsv") |>
       fetch_ads |>
       CSV.read;

julia> Tables.schema(data)
Tables.Schema:
 :posid             Int64
 :oid               Int64
 :adtitle           String
 :position_type_id  Int64
 :position_type     String
 :adtext            String
 :categories        Date
 :startdate         Date
 :enddate           Union{Missing, String}
 :country_code      Union{Missing, String}
 :position_country  String
 :department        String
 :shortname         Union{Missing, String}
 :address           Union{Missing, Float64}
 :longitude         Union{Missing, Float64}
 :latitude          String
 :name              Bool
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
