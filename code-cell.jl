include("repl.jl")

function code_cell(code)
    input = Input(code)
    hbox(
        code_io(code, input) |> size(27em, 37em),
        hskip(1em),
        vbox(
            consume(showoutput, input, typ=Any)
        ) |> size(25em, 35em) |> Escher.pad(1em) |> fillcolor("white") |> roundcorner(0.5em)
    ) |> Escher.pad(1em) |> fillcolor("#e1e4e8") |> paper(2)
end


function main(window)
    push!(window.assets, "codemirror")

    code_cell("[1:10]") |> vbox |> packacross(center) |> pad(2em)
end
