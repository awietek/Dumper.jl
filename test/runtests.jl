using Dumper
using Test

@testset "Dumper.jl" begin
    # Write your tests here.
    fname = "test.h5"
    rm(fname, force=true)
    
    fl = DumpFile(fname)

    x = rand()
    y = rand()
    z = rand()
    
    u = rand(3)
    v = rand(3)
    w = rand(3)
    
    A = rand(3, 4)
    B = rand(3, 4)
    C = rand(3, 4)
    
    # test read/write scalar
    write_data!(fl, "x", x)
    xr = read_data(fl, "x")
    @test isapprox(x, xr)

    write_data!(fl, "y", y)
    yr = read_data(fl, "y")
    @test isapprox(y, yr)

    write_data!(fl, "z", z)
    zr = read_data(fl, "z")
    @test isapprox(z, zr)
    
    # test read/write vector
    write_data!(fl, "u", u)
    ur = read_data(fl, "u")
    @test isapprox(u, ur)

    write_data!(fl, "v", v)
    vr = read_data(fl, "v")
    @test isapprox(v, vr)

    write_data!(fl, "w", w)
    wr = read_data(fl, "w")
    @test isapprox(w, wr)

    # test read/write matrix
    write_data!(fl, "A", A)
    Ar = read_data(fl, "A")
    @test isapprox(A, Ar)

    write_data!(fl, "B", B)
    Br = read_data(fl, "B")
    @test isapprox(B, Br)

    write_data!(fl, "C", C)
    Cr = read_data(fl, "C")
    @test isapprox(C, Cr)

    # Test dumping
    dump!(fl, "scalar", x)
    dump!(fl, "scalar", y)
    dump!(fl, "scalar", z)
    data = read_data(fl, "scalar")
    @test isapprox(data[1], x)
    @test isapprox(data[2], y)
    @test isapprox(data[3], z)


    dump!(fl, "vector", u)
    dump!(fl, "vector", v)
    dump!(fl, "vector", w)
    data = read_data(fl, "vector")
    @test isapprox(data[1,:], u)
    @test isapprox(data[2,:], v)
    @test isapprox(data[3,:], w)

    dump!(fl, "matrix", A)
    dump!(fl, "matrix", B)
    dump!(fl, "matrix", C)
    data = read_data(fl, "matrix")
    @test isapprox(data[1,:,:], A)
    @test isapprox(data[2,:,:], B)
    @test isapprox(data[3,:,:], C)

    fl["testA"] = A
    Arr = fl["testA"]
    @test isapprox(Arr, A)

    fl["testv"] = v
    vrr = fl["testv"]
    @test isapprox(vrr, v)
    
    fl["testx"] = x
    xrr = fl["testx"]
    @test isapprox(xrr, x)


    dump!(fl, "matrix2", A)
    dump!(fl, "matrix2", B)
    dump!(fl, "matrix2", C)
    data = fl["matrix2"]
    @test isapprox(data[1,:,:], A)
    @test isapprox(data[2,:,:], B)
    @test isapprox(data[3,:,:], C)
    
    rm(fname)
end
