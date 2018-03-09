
symengine_win32 <- "https://anaconda.org/symengine/symengine/0.3.0.353.g22cef70/download/win-32/symengine-0.3.0.353.g22cef70-vc14_0.tar.bz2"
symengine_win64 <- "https://anaconda.org/symengine/symengine/0.3.0.353.g22cef70/download/win-64/symengine-0.3.0.353.g22cef70-vc14_0.tar.bz2"

mpc_win32 <- "https://anaconda.org/conda-forge/mpc/1.0.3/download/win-32/mpc-1.0.3-vc14_4.tar.bz2"
mpc_win64 <- "https://anaconda.org/conda-forge/mpc/1.0.3/download/win-64/mpc-1.0.3-vc14_4.tar.bz2"

mpfr_win32 <- "https://anaconda.org/conda-forge/mpfr/3.1.5/download/win-32/mpfr-3.1.5-vc14_0.tar.bz2"
mpfr_win64 <- "https://anaconda.org/conda-forge/mpfr/3.1.5/download/win-64/mpfr-3.1.5-vc14_0.tar.bz2"

mpir_win32 <- "https://anaconda.org/conda-forge/mpir/3.0.0/download/win-32/mpir-3.0.0-vc14_0.tar.bz2"
mpir_win64 <- "https://anaconda.org/conda-forge/mpir/3.0.0/download/win-64/mpir-3.0.0-vc14_0.tar.bz2"

is_32 <- function () {
    machine <- Sys.info()[["machine"]]
    
    if (machine == "x86_64")
        use_32 <- FALSE
    else if (machine == "x86")
        use_32 <- TRUE
    else
        stop("Unrecognized type of machine, which should be either 'x86' or 'x86_64' ??")
}

download_symengine <- function () {
    if (file.exists("../win-symengine/Library/lib/symengine.lib"))
        return()
    
    if (is_32())
        link <- symengine_win32
    else
        link <- symengine_win64
    download.file(link, "symenginelib.tar.bz2", quiet = FALSE)
    if (!dir.exists("../win-symengine"))
        dir.create("../win-symengine")
    untar("symenginelib.tar.bz2", exdir = "../win-symengine", tar = "internal")
    unlink("symenginelib.tar.bz2")
}

download_mpc <- function () {
    if (file.exists("../win-mpc/Library/lib/mpc.lib"))
        return()
    
    if (is_32())
        link <- mpc_win32
    else
        link <- mpc_win64
    download.file(link, "mpclib.tar.bz2", quiet = FALSE)
    if (!dir.exists("../win-mpc"))
        dir.create("../win-mpc")
    untar("mpclib.tar.bz2", exdir = "../win-mpc", tar = "internal")
    unlink("mpclib.tar.bz2")
}

download_mpfr <- function () {
    if (file.exists("../win-mpfr/Library/lib/mpfr.lib"))
        return()
    
    if (is_32())
        link <- mpfr_win32
    else
        link <- mpfr_win64
    download.file(link, "mpfrlib.tar.bz2", quiet = FALSE)
    if (!dir.exists("../win-mpfr"))
        dir.create("../win-mpfr")
    untar("mpfrlib.tar.bz2", exdir = "../win-mpfr", tar = "internal")
    unlink("mpfrlib.tar.bz2")
}

download_mpir <- function () {
    if (file.exists("../win-mpir/Library/lib/gmp.lib"))
        return()
    
    if (is_32())
        link <- mpir_win32
    else
        link <- mpir_win64
    download.file(link, "mpirlib.tar.bz2", quiet = FALSE)
    if (!dir.exists("../win-mpir"))
        dir.create("../win-mpir")
    untar("mpirlib.tar.bz2", exdir = "../win-mpir", tar = "internal")
    unlink("mpirlib.tar.bz2")
}

# Ensure we are in the correct directory
stopifnot(file.exists("../DESCRIPTION"))

download_symengine()
download_mpc()
download_mpfr()
download_mpir()


