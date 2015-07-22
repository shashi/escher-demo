using Markdown
using Color
using SymPy

include("repl.jl")

presentable(x) = Escher.fontsize(1.5em, lineheight(2em, x))

codeslide(code) = begin
    input = Input(code)
    hbox(
        code_io(code, input) |> size(27em, 37em),
        hskip(1em),
        vbox(
            lift(showoutput, input, typ=Any)
        ) |> size(25em, 35em) |> Escher.pad(1em) |> fillcolor("white") |> roundcorner(0.5em)
    ) |> Escher.pad(1em) |> fillcolor("#e1e4e8") |> paper(2)
end

indent(x) = Escher.pad([left], 3em, x) |> Escher.fontsize(0.8em) |> lineheight(1.5em)

function main(window)
    push!(window.assets, "animation")
    push!(window.assets, "widgets")
    push!(window.assets, "tex")
    push!(window.assets, "codemirror")

    slideshow([
        vbox(
            title(4, "A Virtual DOM on the Server?"),
            title(2, "What?"),
            vskip(4em),
            title(1, "Shashi Gowda"),
            title(1, "@g0wda"),
            title(1, "shashi.github.io/Escher.jl")
        ),
        title(2, md"Yes. Settle for nothing less!"),
        title(2, md"\"Recommendation system\": 33 SLOC"),
        title(2, md"Trade data viewer: 194 SLOC"),
        title(2, md"2D FFT of video stream: 13 SLOC"),
        title(2, md"A sierpinski's triangle: 24 SLOC"),
        title(2, md"Minesweeper: 70 SLOC"),
        #include(joinpath(pwd(), "minesweeper.jl"))(window),
        title(2, md"Boids: 84 SLOC (credits: Iain Dunning github.com/IainNZ)"),
        vbox(
            title(3, "The DOM"),
            vskip(2em),
            title(4, "¯\\_(ツ)_/¯"),
        ) |> packacross(center),
        vbox(
            title(3, "DOM is state."),
            vskip(2em),
            title(1, "Bad DOM!"),
            vskip(2em),
            vbox(
                md"- Callbacks and State are the evil king and queen",
                  md"""
                  - They necessitate each other
                  - We increasingly understand that callbacks are not ideal""" |> indent,
                md"- State leads to combinatorial explosion.",
                  md"- Average person can hold < 10 things in his brain at a time" |> indent,
                  md"- But 2^50 = 10^15, there are 10^11 stars in the Milky Way" |> indent,
                  md"- I hope DOM is remembered as a WTF moment from the Web's dark past" |> indent
              ) |> presentable
        ),
        vbox(
            title(3, "Virtual DOM"),
            vskip(1em),
            "The Insurgency" |> Escher.fontsize(1.5em),
            vskip(1em),
            vbox(
                md"- Enables stateless functions",
                md"""
                  - A very simple model
                  - `f : Data -> UI`
                  - What you are doing actually fits in your head
                """ |> indent,
                md"- One clever trick: DOM reconciliation",
                md"- managed efficiency" |> indent,
                md"- Gets along oh so well with FRP",
                md"- An escape hatch from Callback Hell" |> indent
            ) |> presentable
        ),
        vbox(
            title(3, "Over to the dark side!"),
            vskip(1em),
            title(2, "Virtual DOM on the server"),
            vskip(3em),
            image("http://i.giphy.com/UY6K0O5xNeG2s.gif", alt="The Eye of Sauron"),
        ),
        vbox(
            title(3, "The lowest level of abstraction"),
            vskip(2em),
            title(2, "Patchwork.jl"),
            title(1, "github.com/shashi/Patchwork.jl"),
            vskip(1em),
            title(2, "virtual-dom"),
            title(1, "github.com/Matt-Esch/virtual-dom"),
        ),
        vbox(
            title(3, md"**Patchwork.jl** provides the `Elem` type"),
            vskip(2em),
            codeslide("""
            Elem(:div, "Hello, World",
                style=[
                  :padding => 1em,
                  :backgroundColor => "steelblue",
                  :color => "white"
                ]
            )""")
        ),
        slide(vbox(
            title(3, md"**Patchwork.jl** provides the `Elem` type"),
            vskip(2em),
            codeslide("""
                mkcircle(x, y, r, color="lightgrey") =
                    Elem(:svg, :circle,
                        cx=x, cy=y, r=r,
                        style=[:fill => color],
                    )

                Elem(:svg, :svg, [
                    mkcircle(100, 100, 50),
                    mkcircle(100, 200, 70),
                    mkcircle(100, 100, 10, "orange"),
                    mkcircle(80, 80, 10, "white"),
                    mkcircle(120, 80, 10, "white")
                 ], width=500px, height=500px)
                """)
        ), transitions="cross-fade-all"),
        slide(vbox(
            title(3, md"HTML5 Custom Elements work with Virtual DOM!"),
            vskip(2em),
            codeslide("""
            Elem("ka-tex",
                source=\"\"\"
                    cos(2\\\\theta) =
                    cos^2 \\\\theta - sin^2 \\\\theta\"\"\",
                block=true
            )
            """)
        ) |> packacross(center), transitions="cross-fade-all"),
        vbox(
            title(4, "Escher.jl"),
            vskip(1em),
            title(1, "shashi.github.io/Escher.jl"),
            vskip(1em),
            "Delicious layers of pixie dust on top of Virtual DOM" |> Escher.fontsize(1.5em)
        ),
        vbox(
            title(1, md"Abstraction 1"),
            title(2, md"Content: Julia Values to Virtual DOM"),
        ),
        vbox(
            title(2, md"Content: Textual"),
            codeslide("""
            "Hello, World"
            # Markdown.
            #
            # using SymPy
            # x = Sym("x")
            # SymPy.diff(sin(x^2), x, 5)
            """)
        ),
        vbox(
            title(2, md"Content: Vector graphics"),
            codeslide("""
            using Compose

            function sierpinski(n::Int)
                if n == 0
                    compose(context(), polygon([(1,1), (0,1), (1/2, 0)]))
                else
                    t = sierpinski(n - 1)
                    compose(context(),
                            (context(1/4,   0, 1/2, 1/2), t),
                            (context(  0, 1/2, 1/2, 1/2), t),
                            (context(1/2, 1/2, 1/2, 1/2), t))
                end
            end

            drawing(4inch, (2*√3)*inch, sierpinski(2))
            """)
        ),
        vbox(
            title(1, md"Abstraction 2"),
            title(2, md"TeX-style Layouts"),
        ),
        vbox(
            hbox(title(2, md"Layouts"), hskip(1em), "" |>
                Escher.fontsize(1.5em)) |>
                packacross(center),
            codeslide("""
            # using Color
            colors = colormap("reds", 7)

            box1 = container(10em, 10em) |> fillcolor(colors[3])
            box2 = container(5em, 5em) |> fillcolor(colors[5])

            vbox(box1, box2)
            #boxes = [container((5 + i)*em, (5 + i)*em) |>
            #    fillcolor(colors[i])
            #       for i=1:7]

            """)
        ),
        vbox(
            h1("The programming model"), vskip(1em), title(3, tex("UI = f(data)")),
        ),
        vbox(
            h1("The programming model"), vskip(1em), title(3, tex("UI_t = f(data_t)")),
        ),
        title(3, md"But *how*? - for the JavaScript geek"),
        vbox(intersperse(vskip(2em), [
          "f(data) ⟶ UI object",
          md"UI object ⟶ Virtual DOM (on the *server*, yes, on the server!)",
          "Virtual DOM (server) ⟶ JSON ⟶ Virtual DOM (client)",
          "Virtual DOM (client) ⟶ Browser DOM",
        ])) |> Escher.fontsize(2em),
        title(1, "Updates are sent as patches to the Virtual DOM"),
        image("/assets/img/dynamicui.png"),
        #include(joinpath(pwd(), "latex.jl"))(window),
        vbox(
            title(3, "Fully loaded"),
            "Text, Markdown, TeX-style Layout, Type scales, 2D Vector graphics (Compose), Plots (Gadfly), Widgets (thanks polymer!), Composable behavior, 3D Graphics!, A camera!, slideshows" |> width(20em) |> Escher.fontsize(2em) |> lineheight(2em),
        ),
        vbox(
            title(3, "Thanks for the inspiration, and code!"),
            md"""
            - Elm
            - virtual-dom
            - $\KaTeX$
            """ |> lineheight(2em) |> Escher.fontsize(2em)
        ),
        vbox(
            title(3, "Thank you for listening!"), vskip(1em),
            title(2, "https://shashi.github.io/Escher.jl"), vskip(1em),
            title(1, "or just google Escher.jl"),
        ),
    ])
end

