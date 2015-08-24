
using Gadfly

include("repl.jl")

function code_cell(code)
    input = Input(code)
    hbox(
        code_io(code, input) |> size(27em, 37em),
        hskip(1em),
        vbox(
            consume(showoutput, input, typ=Any)
        ) |> size(40em, 35em) |> Escher.pad(1em) |> fillcolor("white") |> roundcorner(0.5em)
    ) |> Escher.pad(1em) |> fillcolor("#e1e4e8") |> paper(2)
end

# Sierpinski
using Color, Compose
const colors = distinguishable_colors(6)
function sierpinski(n, colorindex=1)
    if n == 0
        compose(context(), circle(0.5,0.5,0.5), fill(colors[colorindex]))
    else
        colorindex = colorindex % length(colors) + 1
        t1 = sierpinski(n - 1, colorindex)
        colorindex = colorindex % length(colors) + 1
        t2 = sierpinski(n - 1, colorindex)
        colorindex = colorindex % length(colors) + 1
        t3 = sierpinski(n - 1, colorindex)
        compose(context(),
                (context(1/4,   0, 1/2, 1/2), t1),
                (context(  0, 1/2, 1/2, 1/2), t2),
                (context(1/2, 1/2, 1/2, 1/2), t3))
    end
end

# n steps of Newton iteration for sqrt(a), starting at x
function newton(a, x, n)
    for i = 1:n
        x = 0.5 * (x + a/x)
    end
    return x
end

function matchdigits(x::Number, x0::Number)
    s = string(x)
    s0 = string(x0)
    buf = IOBuffer()
    i = 0
    while (i += 1) <= length(s)
        if s[i] == s0[i]
            print(buf, s[i])
            else
                break
        end
        print(buf, s[i])
    end
    hbox(fontweight(bold, takebuf_string(buf)), s[i:end])
end

set_bigfloat_precision(1024)
sqrt2 = sqrt(big(2))


# Mat Mul


function matmul_ijk(a,b,stop)
    step=0
    n=size(a,1)
    c=zeros(a)
    for i=1:n, j=1:n, k=1:n  
        if step==stop;  return(c); end
          c[i,j] +=  a[i,k] * b[k,j]
        step+=1
    end
    c
end

function matmul_kji(a,b,stop)
    step=0
    n=size(a,1)
    c=zeros(a)
    for k=1:n, j=1:n, i=1:n  
        if step==stop;  return(c); end
        c[i,j] +=  a[i,k] * b[k,j]
        step+=1
    end
    c
end

matmuls = [
    "matmul_ijk" => matmul_ijk,
    "matmul_kji" => matmul_kji
]

n=10
o=int(ones(n,n))


# SVD

using Images
#run(`wget --no-check-certificate https://www2.maths.ox.ac.uk/new.direction2015/images/trefethen_color.jpg`)
const A=imread("trefethen_color.jpg")
function get_compressed(k)
    arrays = float(separate(A.data))
    uR,sR,vR=svd(arrays[:,:,1])
    uG,sG,vG=svd(arrays[:,:,2])
    uB,sB,vB=svd(arrays[:,:,3])

    Image(map(RGB, 
        uR[:,1:k]*diagm(sR[1:k])*vR[:,1:k]',
        uG[:,1:k]*diagm(sG[1:k])*vG[:,1:k]',
        uB[:,1:k]*diagm(sB[1:k])*vB[:,1:k]'))'
end

function main(window)
    push!(window.assets, "codemirror")
    push!(window.assets, "animation")
    push!(window.assets, "widgets")
    push!(window.assets, "tex")

    steps = Input(0)
    newton_steps = Input(1)
    stop = Input(0)
    compress_iter = Input(1)
    matmul_order = Input("matmul_ijk")
    lift(println, matmul_order)

    slideshow([
       title(4, "Escher") |> letterspacing(-.05em),
        vbox(
           title(2, "Random walk"),
           vskip(1em),
           plot(x=1:1000, y=cumsum(randn(1000)), Geom.line)
       ),

        vbox(
            title(2, "Sierpinski's triangle"),
            vskip(1em),
            slider(0:6) >>> steps,
            consume(steps) do n
                drawing(5inch, 5inch, sierpinski(n))
            end
        ),

        vbox(
            title(2, "Convergence of Newton's method"),
            vskip(1em),
            "Number of steps:",
            slider(1:6) >>> newton_steps,
            consume(newton_steps) do n
                (
                    matchdigits(newton(big(2), 2, n), sqrt2)
                ) |> vbox |> width(30em)
            end
        ),

        vbox(
            title(2, "Matrix multiplication"),

            radiogroup([
                radio("matmul_ijk", "i-j-k"),
                radio("matmul_kji",  "k-j-i"),
            ], selected="matmul_ijk") >>> matmul_order,

            slider(1:n^3) >>> stop,
            consume(stop, matmul_order) do n, ord

                codemirror(
                    string(matmuls[ord](o,o,n)),
                    readonly=true
                )
            end
        ),

        vbox(
            title(2, "Image compression with SVD"),
            slider(1:30) >>> compress_iter,
            consume(get_compressed, compress_iter)
        ) |> packacross(center),

        vbox(
            title(2, "Code cell"),
            vskip(1em),
            code_cell("""
            freq = Input(1.0)

            vbox(
                slider(1:1:10.0) >>> freq,
                consume(freq) do f
                    plot(x -> sin(f*x), 0, 10)
                end
            )
            """)
        ),

        title(3, "Thank you")
    ])
end
