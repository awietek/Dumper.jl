struct FileCollection
    directory::AbstractString
    regex::Regex
end

function filenames(collection::FileCollection)
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

function read_collection_h5(collection::FileCollection, tag::AbstractString)
    files = readdir(collection.directory)
    data = Dict()
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
                dset = h5read(file, tag)
                ndims = length(size(dset))
                data[param] = permutedims(dset, ndims:-1:1)
            catch
                println("cannot read from file", file)
            end
        end
    end
    return sort(collect(data), by = x->x[1])
end
