
using SymPy

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
    push!(window.assets, "animation")
    push!(window.assets, "widgets")
    push!(window.assets, "tex")

    slideshow([
       title(2, "Escher examples"),
        vbox(
           title(2, "Simple code cell"),
           vskip(1em),
           code_cell("rand(10,2)"),
       ),

        vbox(
            title(2, "Symbolic Differentiation"),
            vskip(1em),
            code_cell("""
            using SymPy
            x = Sym("x")
            SymPy.diff(sin(x^2), x, 5)
            """),
        ),

        vbox(
            title(2, "Interactive Symbolic Differentiation"),
            vskip(1em),
            code_cell("""
            using SymPy
            x = Sym("x")

            iter = Input(0)
            vbox(
                slider(1:10) >>> iter,
                consume(it -> SymPy.diff(sin(x^2), x, it), iter)
            )
            """),
        ),

        title(3, "Thank you")
    ])
end
