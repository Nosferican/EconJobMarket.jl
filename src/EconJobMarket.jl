"""
    EconJobMarket
An interface with the [EconJobMarket](https://econjobmarket.org/pages/about) [API](https://backend.econjobmarket.org/new_api).
"""
module EconJobMarket
    using Cascadia: nodeText, parsehtml, Selector
    using CSV: CSV, Tables, normalizename, Tables.columntable
    using Dates: Date
    using HTTP: HTTP
    using JSON3: JSON3

    include("utils.jl")
    include("job_ads.jl")
    export CSV, Tables,
           fetch_ads
end
