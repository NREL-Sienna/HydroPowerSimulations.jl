using Documenter, HydroPowerSimulations
import DataStructures: OrderedDict

pages = OrderedDict(
    "Welcome Page" => "index.md",
    "Quick Start Guide" => "quick_start_guide.md",
    "Tutorials" => Any["tutorials/single_stage_model.md"],
    "Formulation Library" => "formulation.md",
    "Public API Reference" => "api/public.md",
    "Internal API Reference" => "api/internal.md",
)

makedocs(
    modules=[HydroPowerSimulations],
    format=Documenter.HTML(;
        mathengine=Documenter.MathJax(),
        prettyurls=haskey(ENV, "GITHUB_ACTIONS"),
    ),
    sitename="HydroPowerSimulations.jl",
    pages=Any[p for p in pages],
)

deploydocs(
    repo="github.com/NREL-Sienna/HydroPowerSimulations.jl.git",
    target="build",
    branch="gh-pages",
    devbranch="main",
    devurl="dev",
    push_preview=true,
    versions=["stable" => "v^", "v#.#"],
)
