using Markdown
using Interact

Compose.set_default_graphic_size(2inch, 2inch)


codecell(input, output=eval(parse("begin $input end")); f = x -> x) =
    vbox(
        codemirror(input),
       vskip(1em),
       output |> f
    ) |> Escher.pad([left], 4em)

points_f = [
    (.1, .1),
    (.9, .1),
    (.9, .2),
    (.2, .2),
    (.2, .4),
    (.6, .4),
    (.6, .5),
    (.2, .5),
    (.2, .9),
    (.1, .9),
    (.1, .1)
]

f = compose(context(), stroke("black"), line(points_f))

rot(pic) = compose(context(rotation=Rotation(-deg2rad(90))), pic)
flip(pic) = compose(context(mirror=Mirror(deg2rad(90), 0.5w, 0.5h)), pic)
above(m, n, p, q) =
    compose(context(),
            (context(0, 0, 1, m/(m+n)), p),
            (context(0, m/(m+n), 1, n/(m+n)), q))

above(p, q) = above(1, 1, p, q)

beside(m, n, p, q) =
    compose(context(),
            (context(0, 0, m/(m+n), 1), p),
            (context(m/(m+n), 0, n/(m+n), 1), q))

beside(p, q) = beside(1, 1, p, q)

over(p, q) = compose(context(),
                (context(), p), (context(), q))

rot45(pic) =
    compose(context(0, 0, 1/sqrt(2), 1/sqrt(2),
        rotation=Rotation(-deg2rad(45), 0w, 0h)), pic)

# Utility function to zoom out and look at the context
zoomout(pic) = compose(context(),
                (context(0.2, 0.2, 0.6, 0.6), pic),
                (context(0.2, 0.2, 0.6, 0.6), fill(nothing), stroke("black"), strokedash([0.5mm, 0.5mm]),
                    polygon([(0, 0), (1, 0), (1, 1), (0, 1)])))

function read_path(p_str)
    tokens = [try parsefloat(x) catch symbol(x) end for x in split(p_str, r"[\s,]+")]
    path(tokens)
end

fish = compose(context(units=UnitBox(260, 260)), stroke("black"),
            read_path(strip(readall("fish.path"))))

rotatable(pic) = @manipulate for θ=0:0.001:2π
    compose(context(rotation=Rotation(θ)), pic)
end

blank = compose(context())

fliprot45(pic) = rot45(compose(context(mirror=Mirror(deg2rad(-45))),pic))

fish2 = fliprot45(fish)
fish3 = rot(rot(rot(fish2)))
t = over(fish, over(fish2, fish3))
u = over(over(fish2, rot(fish2)),
         over(rot(rot(fish2)), rot(rot(rot(fish2)))))

quartet(p, q, r, s) =
    above(beside(p, q), beside(r, s))

cycle(p) =
    quartet(p, rot(p), rot(rot(p)), rot(rot(rot(p))))

nonet(p, q, r,
      s, t, u,
      v, w, x) =
        above(1,2,beside(1,2,p,beside(1,1,q,r)),
        above(1,1,beside(1,2,s,beside(1,1,t,u)),
        beside(1,2,v,beside(1,1,w,x))))

side1 = quartet(blank, blank, rot(t), t)
side2 = quartet(side1,side1,rot(t),t)

side(n) =
    if n == 1 side1 # basis
    else quartet(side(n-1),side(n-1),rot(t),t) # induction
    end

corner1 = quartet(blank,blank,blank,u)
corner2 = quartet(corner1,side1,rot(side1),u)
corner(n) =
    n == 1 ? corner1 :
             quartet(corner(n-1), side(n-1), rot(side(n-1)), u)
squarelimit(n) =
    nonet(corner(n), side(n), rot(rot(rot(corner(n)))),
          rot(side(n)), u, rot(rot(rot(side(n)))),
          rot(corner(n)), rot(rot(side(n))), rot(rot(corner(n))))

midsize(p) = drawing(4inch, 4inch, p)
largesize(p) = drawing(10inch, 10inch, p)

function main(window)
    drawing(10inch, 10inch, squarelimit(3))
    push!(window.assets, "codemirror")

md"""

$(title(3, "Functional Geometry"))

*Functional Geometry* is a paper by Peter Henderson ([original (1982)](users.ecs.soton.ac.uk/peter/funcgeo.pdf), [revisited (2002)](https://cs.au.dk/~hosc/local/HOSC-15-4-pp349-365.pdf)) which deconstructs the MC Escher woodcut *Square Limit*

> A picture is an example of a complex object that can be described in terms of its parts.  Yet a picture needs to be rendered on a printer or a screen by a device that expects to be given a sequence of commands. Programming that sequence of commands directly is much harder than having an application generate the commands automatically from the simpler, denotational description.

$(image("http://i.imgur.com/LjRzmNM.png") |> hbox |> packitems(center))

# Introduction

A `picture` is a *denotation* of something to draw.

e.g. The value of f here denotes the picture of the letter F

$(codecell("f"))

## Basic Operations on Pictures

We begin specifying the algebra of pictures we will use to describe *Square Limit* with a few operations that operate on pictures to give other pictures, namely:

* `rot    : picture → picture`
* `flip   : picture → picture`
* `rot45  : picture → picture`
* `above  : picture × picture → picture`
* `above  : int × int × picture × picture → picture`
* `beside : picture × picture → picture`
* `beside : int × int × picture × picture → picture`
* `over   : picture → picture`

## Rotate and flip

### rot : picture → picture

Rotate a picture anti-clockwise by 90°

$(codecell("rot(f)"))

### flip : picture → picture

Flip a picture along its virtical center axis

$(codecell("flip(f)"))
$(codecell("rot(flip(f))"))

### fliprot45 : picture → picture

rotate the picture anti-clockwise by 45°, then flip it across the new virtical axis. In the paper this is implemented as `flip(rot45(fish))`. This function is rather specific to the problem at hand.

$(codecell("fliprot45(fish)", fliprot45(fish) |> zoomout))

## Juxtaposition

#### `above  : picture × picture → picture`

place a picture above another.

$(codecell("above(f, f)"))

#### `above  : int × int × picture × picture → picture`

given `m`, `n`, `picture1` and `picture2`, return a picture where `picture1` is placed above `picture2` such that their heights occupy the total height in m:n ratio

$(codecell("above(1, 2, f, f)"))

#### `beside : picture × picture → picture`

Similar to `above` but in the left-to-right direction.

$(codecell("beside(f, f)"))

### `beside : int × int × picture × picture → picture`

$(codecell("beside(1, 2, f, f)"))


$(codecell("above(beside(f, f), f)"))

## Superposition

### `over : picture → picture`

place a picture upon another

$(codecell("over(f, flip(f))"))

# Square Limit

## The Fish

We will now study some of the properties of the fish.

$(codecell("fish |> zoomout"))

$(codecell("over(fish, rot(rot(fish))) |> zoomout"))

## Tiles

There is a certain kind of arrangement that is used to tile parts of the image. We call it `t`

$(codecell(
"fish2 = fliprot45(fish)
fish3 = rot(rot(rot(fish2)))

t = over(fish, over(fish2, fish3))

t |> zoomout
"))

$(codecell(

"u = over(over(fish2, rot(fish2)),
         over(rot(rot(fish2)), rot(rot(rot(fish2)))))

u |> zoomout
"))

## Tesselations

`quartet` tiles 4 images in a 2x2 grid

$(codecell(
"quartet(p, q, r, s) =
    above(beside(p, q), beside(r, s))

quartet(f,flip(f),rot(f),f)
"))

Notice how the fish interlock without leaving out any space in between them. Escher FTW.

`cycle` is a quartet of the same picture with each successive tile rotated by 90° anti-clockwise

$(codecell(
"cycle(p) =
    quartet(p, rot(p), rot(rot(p)), rot(rot(rot(p))))

cycle(f)
"))

A nonet is a 3 × 3 grid of 9 pictures.

$(codecell(
"nonet(p, q, r,
      s, t, u,
      v, w, x) =
        above(1,2,beside(1,2,p,beside(1,1,q,r)),
        above(1,1,beside(1,2,s,beside(1,1,t,u)),
        beside(1,2,v,beside(1,1,w,x))))

nonet(f, f, f, f, f, f, f, f, f) "))

## Sides and Corners of The Square Limit

Note: `blank` denotes a blank `picture`

There is a certain pattern which makes up the mid region of each of the four edges of the image. We will call this arrangement `side`

the 1 in `side1` represents 1 level of recursion. This is the simplest side.

$(codecell(
"side1 = quartet(blank, blank, rot(t), t)

side1 |> zoomout", f=midsize))

A side that is 2 levels deep.

$(codecell(
"side2 = quartet(side1,side1,rot(t),t)

side2 |> zoomout", f=midsize))

n-levels deep:

$(codecell(
"side(n) =
    if n == 1 side1 # basis
    else quartet(side(n-1),side(n-1),rot(t),t) # induction
    end

side(3) |> zoomout
", f=midsize))

Similarly, there is a certain kind of arrangement which makes up the corners of the artwork.

A `corner` 1 level deep is simply

$(codecell(
"corner1 = quartet(blank,blank,blank,u)

corner1 |> zoomout", f=midsize))

A corner 2 levels deep, it is built using corner1, side1 and u.

$(codecell(
"corner2 = quartet(corner1,side1,rot(side1),u)

corner2 |> zoomout", f=midsize))

An n level deep corner.

$(codecell(
"corner(n) =
    n == 1 ? corner1 :
             quartet(corner(n-1), side(n-1), rot(side(n-1)), u)

corner(3) |> zoomout", f=midsize))

# Square limit

Having built up the algebra to describe *Square Limit*, we can now precisely denote it. Square limit is a nonet of right angled rotations of `corner` at the corners, `side` at the sides and `u` in the center. The precise algebra and the code are identical:

$(codecell(
"squarelimit(n) =
    nonet(corner(n), side(n), rot(rot(rot(corner(n)))),
          rot(side(n)), u, rot(rot(rot(side(n)))),
          rot(corner(n)), rot(rot(side(n))), rot(rot(corner(n))))

squarelimit(3)", f=largesize))




""" |> Escher.pad(1em) |> maxwidth(76em)

end
