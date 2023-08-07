module Dumper

using HDF5
using Printf

export DumpFile, dump_open

struct DumpFile
    filename::String
    fid::HDF5.File
end

function dump_open(filename::String)
    fid = h5open(filename, "cw")
    return DumpFile(filename, fid)    
end

end
