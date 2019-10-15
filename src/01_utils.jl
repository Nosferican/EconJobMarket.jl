"""
    clean_name(obj)::Symbol
Normalize the value such that it qualifies as a lowercase valid identifier.
# Example
```jldoctest
julia> EconJobMarket.clean_name(Symbol("3This  is a Cat:egory!4cΩ."))
:_3this_is_a_cat_egory!4cΩ_
```
"""
clean_name(obj)::Symbol =
    join(isascii(elem) ? lowercase(elem) : elem for elem ∈ string(obj)) |>
    normalizename
