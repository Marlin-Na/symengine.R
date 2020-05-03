## We do not use "useDynLib" in NAMESPACE but control it in
## .onLoad() and .onUnload() manually.
## This gives us the flexibility to behave differently on windows
## and unix. On windows, we put additional dlls to the package
## folder and load them via `library.dynam` at run time. On Unix,
## we assume that the dependencies such as gmp are in system path.

library.dynam_2 <- function(chname, package, lib.loc, ...) {
    ## A wrapper around library.dynam that allows it to fail.
    ## Roxygen will try to load the package for generating documentation,
    ## which leads to
    ## > Error in find.package(package, lib.loc, verbose = verbose) : 
    ## >   there is no package called ‘symengine’
    pkgs <- find.package(package, lib.loc, quiet = TRUE)
    if (!length(pkgs)) {
        warning(sprintf("There is no package called %s", package))
        return()
    }
    library.dynam(chname, package, lib.loc, ...)
}

.onLoad <- function(libname, pkgname) {
    register_s3_method("knitr", "knit_print", "Basic")
    set_default_option_if_not("symengine.latex", FALSE)
    set_default_option_if_not("symengine.latex.center", FALSE)

    ## TODO: use assignInMyNamespace to update constants?
    if (.Platform$OS.type == "windows")
        return(.onLoad.windows(libname, pkgname))
    
    library.dynam_2("symengine", pkgname, libname)
}

.onUnload <- function(libpath) {
    if (.Platform$OS.type == "windows")
        return(.onUnload.windows(libpath))
    
    library.dynam.unload("symengine", libpath)
}

.onLoad.windows <- function(libname, pkgname) {
    if (.Platform$r_arch == "")
        library.dynam_2(sprintf("../mylibs/%s/libgmp-10", .Platform$r_arch), pkgname, libname)
    else
        library.dynam_2(sprintf("../../mylibs/%s/libgmp-10", .Platform$r_arch), pkgname, libname)
    ## Currently using static library as workaround
    #library.dynam_2("libsymengine", pkgname, libname)
    library.dynam_2("symengine"   , pkgname, libname)
}

.onUnload.windows <- function(libpath) {
    library.dynam.unload("symengine"   , libpath)
    ## Currently using static library as workaround
    #library.dynam.unload("libsymengine", libpath)
    if (.Platform$r_arch == "")
        library.dynam.unload(sprintf("../mylibs/%s/libgmp-10", .Platform$r_arch), libpath)
    else
        library.dynam.unload(sprintf("../../mylibs/%s/libgmp-10", .Platform$r_arch), libpath)
}

.onAttach <- function (libname, pkgname) {
    ## TODO: print available symengine components

    ## Try to confirm the shared object is loaded, but allow it to fail
    if (!is.loaded("_symengine_compilation_notes")) {
        warning("The shared library is not loaded")
        return(invisible(FALSE))
    }

    version <- symengine_version()
    msg <- sprintf("SymEngine Version: %s", version)
    if (requireNamespace("crayon", quietly = TRUE))
        msg <- crayon::yellow(msg)
    packageStartupMessage(msg)
    
    logo <- symengine_ascii_art()
    if (requireNamespace("crayon", quietly = TRUE)) {
        pres  <- substring(logo, 1, 16)
        posts <- substring(logo, 17)
        
        pres  <- crayon::red(pres)
        posts <- crayon::green(posts)
        
        com <- crayon::`%+%`(pres, posts)
        com <- paste(com, collapse = "\n")
        packageStartupMessage(com)
    }
    else
        packageStartupMessage(logo)
    
    invisible(TRUE)
}


## Reference:
## - https://cran.r-project.org/web/packages/knitr/vignettes/knit_print.html#for-package-authors
## - https://github.com/rstudio/htmltools/pull/108/files
## This avoids hard dependency so that we can put knitr in Suggests
register_s3_method <- function(pkg, generic, class, fun = NULL) {
    stopifnot(is.character(pkg), length(pkg) == 1)
    stopifnot(is.character(generic), length(generic) == 1)
    stopifnot(is.character(class), length(class) == 1)

    if (is.null(fun)) {
        fun <- get(paste0(generic, ".", class), envir = parent.frame())
    } else {
        stopifnot(is.function(fun))
    }

    if (pkg %in% loadedNamespaces()) {
        registerS3method(generic, class, fun, envir = asNamespace(pkg))
    }

    # Always register hook in case package is later unloaded & reloaded
    setHook(
        packageEvent(pkg, "onLoad"),
        function(...) {
            registerS3method(generic, class, fun, envir = asNamespace(pkg))
        }
    )
}

set_default_option_if_not <- function(name, value) {
    opt <- list(value)
    names(opt) <- name
    ori <- getOption(name, default = NULL)
    if (is.null(ori)) {
        return(options(opt))
    }
    invisible(NULL)
}

symengine_cpp_dir <- function() {
    # i.e. "inst/cpplib${R_ARCH}"
    system.file(paste0("cpplib", .Platform$r_arch), package = "symengine", mustWork = TRUE)
}

symengine_py_install <- function(ref = "symengine/symengine.py@4abfe892c56efa6e7b1939b2c78735b4e60d47bb", ...) {
    ## Set SymEngine_DIR to the static library bundled by the installed R package
    oldenv <- Sys.getenv("SymEngine_DIR", unset = NA, names = FALSE)
    on.exit(if (is.na(oldenv)) Sys.unsetenv("SymEngine_DIR")
            else Sys.setenv(SymEngine_DIR = oldenv))
    Sys.setenv(SymEngine_DIR = symengine_cpp_dir())
    
    symengine_py_url <- sprintf("git+https://github.com/%s", ref)
    reticulate::py_install(packages=symengine_py_url, pip=TRUE, ...)
}
