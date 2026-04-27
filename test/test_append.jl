using Test

@testset "Dumper.jl: append_extensible Dimension Checks" begin
    filename = tempname() * ".h5"
    dfile = DumpFile(filename)
    
    @testset "Test Vector Appending" begin
        dump!(dfile, "test_vector", [1.0, 2.0, 3.0])

        @test_logs dump!(dfile, "test_vector", [4.0, 5.0, 6.0]). # It should work with no warning

        # Test warning
        @test_logs (:warn, r"data length \(2\) is shorter than dataset dimension \(3\)") begin
            dump!(dfile, "test_vector", [7.0, 8.0])
        end

        # Test smaller array with warning disabled (Should succeed silently)
        @test_logs dump!(dfile, "test_vector", [9.0]; warn_size_mismatch=false)

        # Test larger array (should throw ErrorException)
        @test_throws ErrorException("Cannot append to dataset \"test_vector\": data length (4) is larger than dataset dimension (3).") begin
            dump!(dfile, "test_vector", [10.0, 11.0, 12.0, 13.0])
        end
    end

    @testset "Test Matrix Appending" begin
        dump!(dfile, "test_matrix", [1.0 2.0; 3.0 4.0])

        # Test same size 
        @test_logs dump!(dfile, "test_matrix", [5.0 6.0; 7.0 8.0])

        # Test smaller matrix 
        @test_logs (:warn, r"data size \(1, 2\) is smaller than dataset dimensions \(2, 2\)") begin
            dump!(dfile, "test_matrix", [9.0 10.0])
        end

        # Test smaller matrix with warning disabled
        @test_logs dump!(dfile, "test_matrix", reshape([11.0], 1, 1); warn_size_mismatch=false)

        # Test larger matrix (3x2 matrix)
        @test_throws ErrorException("Cannot append to dataset \"test_matrix\": data size (3, 2) is larger than dataset dimensions (2, 2).") begin
            dump!(dfile, "test_matrix", [1.0 2.0; 3.0 4.0; 5.0 6.0])
        end
    end

    @testset "Verify that is adding zeros correcly for vector" begin

        vec_data = read_data(dfile, "test_vector")
        
        @test vec_data[3, 3] == 0.0 
        
        @test vec_data[4, 2] == 0.0
        @test vec_data[4, 3] == 0.0
    end

    @testset "Verify that is adding zeros correctly for matrix" begin
        mat_data = read_data(dfile, "test_matrix")
        
        @test mat_data[3, 2, 1] == 0.0 
        @test mat_data[3, 2, 2] == 0.0 
        
        @test mat_data[4, 1, 2] == 0.0
        @test mat_data[4, 2, 1] == 0.0
        @test mat_data[4, 2, 2] == 0.0
    end

    rm(filename, force=true)
end