module Dumper
using HDF5
using Printf

export DumpFile, write_data!, dump!, read_data, FileCollection, filenames, read_collection_h5

include("create_extensible.jl")
include("append_extensible.jl")
include("file_collection.jl")

struct DumpFile
    filename::AbstractString
end

function Base.setindex!(file::DumpFile, data, name::AbstractString)
    write_data!(file, name, data)
end

function Base.getindex(file::DumpFile, name::AbstractString)
    return read_data(file, name)
end

function write_data!(dfile::DumpFile, name::AbstractString, data)
    h5open(dfile.filename, "cw") do fid
        fid[name] = data
    end
end

function write_data!(dfile::DumpFile, name::AbstractString, data::AbstractArray)
    h5open(dfile.filename, "cw") do fid
        fid[name] = permutedims(data)
    end
end


function dump!(dfile::DumpFile, name::AbstractString, data; chunk_size=nothing)
    h5open(dfile.filename, "cw") do fid
        if HDF5.API.h5l_exists(fid, name, HDF5.API.H5P_DEFAULT)
            append_extensible(fid, name, data)
        else
            create_extensible(fid, name, data; chunk_size=chunk_size)
            append_extensible(fid, name, data)
        end        
    end
end

function read_data(dfile::DumpFile, name::AbstractString)
    data = h5read(dfile.filename, name)
    ndims = length(size(data))
    if ndims == 0
        return data
    else
        return permutedims(data, ndims:-1:1)
    end
end

end
