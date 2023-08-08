scalar_chunk_size = 100
vector_chunk_size = 10
matrix_chunk_size = 1

function create_extensible(fid::HDF5.File, name::AbstractString, data; chunk_size=nothing)
    if chunk_size == nothing
        chunk_size = scalar_chunk_size
    end
    dim_t = Tuple{HDF5.hsize_t, HDF5.hsize_t}
    dtype = HDF5.datatype(data)

    dims = dim_t((0, 1))
    max_dims = dim_t((typemax(Int64), 1))
    chunk_dims = dim_t((chunk_size, 1))
   
    dataspace_id = HDF5.API.h5s_create_simple(2, Ref(dims), Ref(max_dims))
    chunk_prop_id = HDF5.API.h5p_create(HDF5.API.H5P_DATASET_CREATE);
    HDF5.API.h5p_set_chunk(chunk_prop_id, 2, Ref(chunk_dims));

    dataset_id = HDF5.API.h5d_create(fid, name, dtype, dataspace_id,
                                     HDF5.API.H5P_DEFAULT,
                                     chunk_prop_id, HDF5.API.H5P_DEFAULT);

    HDF5.API.h5d_close(dataset_id);
    HDF5.API.h5p_close(chunk_prop_id);
    HDF5.API.h5s_close(dataspace_id);
end

function create_extensible(fid::HDF5.File, name::AbstractString, data::Vector{T};
                           chunk_size=nothing) where T
    if chunk_size == nothing
        chunk_size = vector_chunk_size
    end
    N = length(data)
    
    dim_t = Tuple{HDF5.hsize_t, HDF5.hsize_t}
    dtype = HDF5.datatype(T)

    dims = dim_t((0, N))
    max_dims = dim_t((typemax(Int64), N))
    chunk_dims = dim_t((vector_chunk_size, N))

    dataspace_id = HDF5.API.h5s_create_simple(2, Ref(dims), Ref(max_dims))
    chunk_prop_id = HDF5.API.h5p_create(HDF5.API.H5P_DATASET_CREATE);
    HDF5.API.h5p_set_chunk(chunk_prop_id, 2, Ref(chunk_dims));

    dataset_id = HDF5.API.h5d_create(fid, name, dtype, dataspace_id,
                                     HDF5.API.H5P_DEFAULT,
                                     chunk_prop_id, HDF5.API.H5P_DEFAULT);

    HDF5.API.h5d_close(dataset_id);
    HDF5.API.h5p_close(chunk_prop_id);
    HDF5.API.h5s_close(dataspace_id);
end

function create_extensible(fid::HDF5.File, name::AbstractString, data::Matrix{T};
                           chunk_size=nothing) where T
    if chunk_size == nothing
        chunk_size = matrix_chunk_size
    end
    M, N = size(data)
    
    dim_t = Tuple{HDF5.hsize_t, HDF5.hsize_t, HDF5.hsize_t}
    dtype = HDF5.datatype(T)

    dims = dim_t((0, M, N))
    max_dims = dim_t((typemax(Int64), M, N))
    chunk_dims = dim_t((vector_chunk_size, M, N))

    dataspace_id = HDF5.API.h5s_create_simple(3, Ref(dims), Ref(max_dims))
    chunk_prop_id = HDF5.API.h5p_create(HDF5.API.H5P_DATASET_CREATE);
    HDF5.API.h5p_set_chunk(chunk_prop_id, 3, Ref(chunk_dims));

    dataset_id = HDF5.API.h5d_create(fid, name, dtype, dataspace_id,
                                     HDF5.API.H5P_DEFAULT,
                                     chunk_prop_id, HDF5.API.H5P_DEFAULT);

    HDF5.API.h5d_close(dataset_id);
    HDF5.API.h5p_close(chunk_prop_id);
    HDF5.API.h5s_close(dataspace_id);
end
