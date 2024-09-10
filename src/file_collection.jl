import DataStructures: OrderedDict

struct FileCollection
    directory::AbstractString
    regex::Regex
end

"""
    files

Returns which files are matched by the file collection

# Arguments
- `collection::FileCollection`: the file collection to be matched
"""
function files(collection::FileCollection)
    files = readdir(collection.directory)
    matched_files = String[]
    for file in files
        m = match(collection.regex, file)
        if !isnothing(m)
            push!(matched_files, file)
        end
    end
    return map(fl -> joinpath(collection.directory, fl), matched_files)
end

"""
    keys

Returns which keys are defined in the hdf5 files

# Arguments
- `collection::FileCollection`: the file collection for which to get the keys
"""
function keys(collection::FileCollection)
    files = readdir(collection.directory)
    data = OrderedDict()

    for file in files
        m = match(collection.regex, file)
        if !isnothing(m)
            if length(m) == 1
                param = m[Base.keys(m)[1]]
            else
                param = ntuple(i -> m[Base.keys(m)[i]], length(m))
            end
        
            # read hdf5 data
            file = joinpath(collection.directory, file)
            try
                f = h5open(file)
                keys = Base.keys(f)
                data[param] = keys
            catch e
                showerror(stdout, e)
                println()
                println("cannot read from file", file)
            end
        end
    end
    return data
end


"""
    read

reads the data from a file collection given a key

# Arguments
- `collection::FileCollection`: the file collection to be matched
- `key::String`: key for which the data is supposed to be read
"""
function Base.read(collection::FileCollection, key::String)
    files = readdir(collection.directory)
    data = OrderedDict()
    for file in files
        m = match(collection.regex, file)
        if !isnothing(m)
            if length(m) == 1
                param = m[keys(m)[1]]
            else
                param = ntuple(i -> m[keys(m)[i]], length(m))
            end

            # read hdf5 data
            file = joinpath(collection.directory, file)
            try
                dset = h5read(file, key)
                ndims = length(size(dset))
                data[param] = permutedims(dset, ndims:-1:1)
            catch e
                showerror(stdout, e)
                println()
                println("cannot read from file", file)
            end
        end
    end
    return data
end
