module StanModels

const stanmodels_src_path = @__DIR__

"""

# stanmodels_path

Relative path using the StanModels src/ directory. 

### Example to get access to the scripts subdirectory of StanModels
```julia
stanmodels_path("..", "scripts")
```
"""
stanmodels_path(parts...) = normpath(joinpath(stanmodels_src_path, parts...))

using StanSample

include("utils/scale.jl")

export
  stanmodels_path

end # module
