function get_dataset_dims(dataset_id::HDF5.API.hid_t)
    dataspace_id = HDF5.API.h5d_get_space(dataset_id)
    dims, max_dims = HDF5.API.h5s_get_simple_extent_dims(dataspace_id)
    return dims, max_dims
end

function append_extensible(fid::HDF5.File, name::AbstractString, data; warn_size_mismatch::Bool=true)
    dim_t = Tuple{HDF5.API.hsize_t, HDF5.API.hsize_t}
    dtype = HDF5.datatype(data)
    
    dataset_id = HDF5.API.h5d_open(fid, name, HDF5.API.H5P_DEFAULT)
    dims, max_dims = get_dataset_dims(dataset_id)
   
    if length(dims) != 2
        throw(@sprintf("Cannot append to dataset \"%s\": not in shape for a scalar", name))
    end
       
    dataspace_id = HDF5.API.h5d_get_space(dataset_id)
    new_dims = dim_t((dims[1]+1, dims[2]))
    HDF5.API.h5d_set_extent(dataset_id, Ref(new_dims))
    
    # Write to a subselection
    filespace_id = HDF5.API.h5d_get_space(dataset_id)
    offset = dim_t((dims[1], 0))
    stride = dim_t((1, 1))
    count = dim_t((1, 1))
    block = dim_t((1, 1))


    HDF5.API.h5s_select_hyperslab(filespace_id, HDF5.API.H5S_SELECT_SET, Ref(offset),
                                  Ref(stride), Ref(count), Ref(block))

    memspace_id = HDF5.API.h5s_create_simple(2, Ref(count), Ref(count))
    HDF5.API.h5d_write(dataset_id, dtype, memspace_id, filespace_id,
                       HDF5.API.H5P_DEFAULT, Ref(data))

    HDF5.API.h5s_close(memspace_id)
    HDF5.API.h5s_close(filespace_id)
    HDF5.API.h5s_close(dataspace_id)
    HDF5.API.h5d_close(dataset_id)
end

function append_extensible(fid::HDF5.File, name::AbstractString, data::Vector{T}; warn_size_mismatch::Bool=true) where T
    N = length(data)
    
    dim_t = Tuple{HDF5.API.hsize_t, HDF5.API.hsize_t}
    dtype = HDF5.datatype(T)
    
    dataset_id = HDF5.API.h5d_open(fid, name, HDF5.API.H5P_DEFAULT)
    dims, max_dims = get_dataset_dims(dataset_id)
   
    if length(dims) != 2
        throw(@sprintf("Cannot append to dataset \"%s\": not in shape for a vector", name))
    end

    if N > dims[2]
        error(@sprintf("Cannot append to dataset \"%s\": data length (%d) is larger than dataset dimension (%d).", name, N, dims[2]))
    elseif N < dims[2] && warn_size_mismatch
        @warn @sprintf("Appending to dataset \"%s\": data length (%d) is shorter than dataset dimension (%d). Missing entries will be padded.", name, N, dims[2])
    end
       
    dataspace_id = HDF5.API.h5d_get_space(dataset_id)
    new_dims = dim_t((dims[1]+1, dims[2]))
    HDF5.API.h5d_set_extent(dataset_id, Ref(new_dims))
    
    # Write to a subselection
    filespace_id = HDF5.API.h5d_get_space(dataset_id)
    offset = dim_t((dims[1], 0))
    stride = dim_t((1, 1))
    count = dim_t((1, N))
    block = dim_t((1, 1))

    HDF5.API.h5s_select_hyperslab(filespace_id, HDF5.API.H5S_SELECT_SET, Ref(offset),
                                  Ref(stride), Ref(count), Ref(block))

    memspace_id = HDF5.API.h5s_create_simple(2, Ref(count), Ref(count))
    HDF5.API.h5d_write(dataset_id, dtype, memspace_id, filespace_id,
                       HDF5.API.H5P_DEFAULT,
                       unsafe_pointer_to_objref(pointer_from_objref(data)))

    HDF5.API.h5s_close(memspace_id)
    HDF5.API.h5s_close(filespace_id)
    HDF5.API.h5s_close(dataspace_id)
    HDF5.API.h5d_close(dataset_id)
end


function append_extensible(fid::HDF5.File, name::AbstractString, data::Vector{<:AbstractString}; warn_size_mismatch::Bool=true)
    N = length(data)

    dim_t = Tuple{HDF5.API.hsize_t, HDF5.API.hsize_t}

    dtype = HDF5.API.h5t_copy(HDF5.API.H5T_C_S1)
    HDF5.API.h5t_set_size(dtype, HDF5.API.H5T_VARIABLE)
    HDF5.API.h5t_set_cset(dtype, HDF5.API.H5T_CSET_UTF8)

    dataset_id = HDF5.API.h5d_open(fid, name, HDF5.API.H5P_DEFAULT)
    dims, max_dims = get_dataset_dims(dataset_id)

    if length(dims) != 2
        throw(@sprintf("Cannot append to dataset \"%s\": not in shape for a vector of strings", name))
    end

    if N > dims[2]
        error(@sprintf("Cannot append to dataset \"%s\": data length (%d) is larger than dataset dimension (%d).", name, N, dims[2]))
    elseif N < dims[2] && warn_size_mismatch
        @warn @sprintf("Appending to dataset \"%s\": data length (%d) is shorter than dataset dimension (%d). Missing entries will be padded.", name, N, dims[2])
    end

    dataspace_id = HDF5.API.h5d_get_space(dataset_id)
    new_dims = dim_t((dims[1]+1, dims[2]))
    HDF5.API.h5d_set_extent(dataset_id, Ref(new_dims))

    filespace_id = HDF5.API.h5d_get_space(dataset_id)
    offset = dim_t((dims[1], 0))
    stride = dim_t((1, 1))
    count = dim_t((1, N))
    block = dim_t((1, 1))

    HDF5.API.h5s_select_hyperslab(filespace_id, HDF5.API.H5S_SELECT_SET, Ref(offset),
                                  Ref(stride), Ref(count), Ref(block))

    memspace_id = HDF5.API.h5s_create_simple(2, Ref(count), Ref(count))

    GC.@preserve data begin
        ptrs = [Base.unsafe_convert(Cstring, s) for s in data]
        HDF5.API.h5d_write(dataset_id, dtype, memspace_id, filespace_id,
                           HDF5.API.H5P_DEFAULT, ptrs)
    end

    HDF5.API.h5s_close(memspace_id)
    HDF5.API.h5s_close(filespace_id)
    HDF5.API.h5s_close(dataspace_id)
    HDF5.API.h5d_close(dataset_id)
    HDF5.API.h5t_close(dtype)
end

function append_extensible(fid::HDF5.File, name::AbstractString, data::Matrix{T}; warn_size_mismatch::Bool=true) where T
    M, N = size(data)
    
    dim_t = Tuple{HDF5.API.hsize_t, HDF5.API.hsize_t, HDF5.API.hsize_t}
    dtype = HDF5.datatype(T)
    
    dataset_id = HDF5.API.h5d_open(fid, name, HDF5.API.H5P_DEFAULT)
    dims, max_dims = get_dataset_dims(dataset_id)
   
    if length(dims) != 3
        throw(@sprintf("Cannot append to dataset \"%s\": not in shape for a matrix", name))
    end

    if M > dims[2] || N > dims[3]
        error(@sprintf("Cannot append to dataset \"%s\": data size (%d, %d) is larger than dataset dimensions (%d, %d).", name, M, N, dims[2], dims[3]))
    elseif (M < dims[2] || N < dims[3]) && warn_size_mismatch
        @warn @sprintf("Appending to dataset \"%s\": data size (%d, %d) is smaller than dataset dimensions (%d, %d). Missing entries will be padded.", name, M, N, dims[2], dims[3])
    end
       
    dataspace_id = HDF5.API.h5d_get_space(dataset_id)
    new_dims = dim_t((dims[1]+1, dims[2], dims[3]))
    HDF5.API.h5d_set_extent(dataset_id, Ref(new_dims))
    
    # Write to a subselection
    filespace_id = HDF5.API.h5d_get_space(dataset_id)
    offset = dim_t((dims[1], 0, 0))
    stride = dim_t((1, 1, 1))
    count = dim_t((1, M, N))
    block = dim_t((1, 1, 1))


    HDF5.API.h5s_select_hyperslab(filespace_id, HDF5.API.H5S_SELECT_SET, Ref(offset),
                                  Ref(stride), Ref(count), Ref(block))

    memspace_id = HDF5.API.h5s_create_simple(3, Ref(count), Ref(count))
    data_perm = permutedims(data)
    HDF5.API.h5d_write(dataset_id, dtype, memspace_id, filespace_id,
                       HDF5.API.H5P_DEFAULT,
                       unsafe_pointer_to_objref(pointer_from_objref(data_perm)))

    HDF5.API.h5s_close(memspace_id)
    HDF5.API.h5s_close(filespace_id)
    HDF5.API.h5s_close(dataspace_id)
    HDF5.API.h5d_close(dataset_id)
end

