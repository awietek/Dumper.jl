# Dumper

[![Build Status](https://github.com/awietek/Dumper.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/awietek/Dumper.jl/actions/workflows/CI.yml?query=branch%3Amain)

A simple package to write successive data into an extensible hdf5 file. Can be used to accululate data from successive time steps in physics simulations.

Usage example:


```julia
using Dumper

fl = DumpFile("test.h5")

# Accumulate three vectors
u = rand(3)
v = rand(3)
w = rand(3)

dump!(fl, "vector", u)
dump!(fl, "vector", v)
dump!(fl, "vector", w)

# read data back in 
data = fl["vector"]
println(isapprox(data[1,:,:], u))
println(isapprox(data[2,:,:], v))
println(isapprox(data[3,:,:], w))


# Accumulate three matrices
A = rand(3, 4)
B = rand(3, 4)
C = rand(3, 4)

dump!(fl, "matrix", A)
dump!(fl, "matrix", B)
dump!(fl, "matrix", C)

# read data back in 
data = fl["matrix"]
println(isapprox(data[1,:,:], A))
println(isapprox(data[2,:,:], B))
println(isapprox(data[3,:,:], C))

# or write a simple matrix
fl["A"] = A
data = fl["A"]
println(isapprox(data, A))
```
   