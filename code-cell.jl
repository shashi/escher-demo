function codecell(code, signal=Signal(Dict()))
    s = sampler()

    editor = watch!(s, :code, codemirror(code))
    code_cell = trigger!(s, :submit, keypress("ctrl+enter shift+enter", editor))

    ui = vbox(
        intent(s, code_cell) >>> signal
    )
    ui, map(x->get(x, :code, code), signal)
end

# Function that executes code and
# returns the result
execute_code(code) = begin
    try
        parse("begin\n" * code * "\nend") |> eval
    catch ex
        sprint() do io
            showerror(io, ex)
            println(io)
            Base.show_backtrace(io, catch_backtrace())
        end
    end
end

# Output area
showoutput(code) = begin
    obj = try
        execute_code(code)
    catch ex
        sprint() do io
            showerror(io, ex)
            println(io)
            Base.show_backtrace(io, catch_backtrace())
        end
    end
    try
        convert(Tile, obj)
    catch codemirror(string(obj), readonly=true, linenumbers=false)
    end
end


codeslide(code) = begin
    ui, sig = codecell(code)
    hbox(
        ui |> size(27em, 37em),
        hskip(1em),
        vbox(
            map(showoutput, sig, typ=Any)
        ) |> size(25em, 25em) |> Escher.pad(1em) |> fillcolor("white") |> roundcorner(0.5em)
    ) |> Escher.pad(1em) |> fillcolor("#e1e4e8") |> paper(2)
end


function main(window)
    push!(window.assets, "codemirror")

    codeslide("1+1")
end
