
library(reticulate)
library(symengine)

reticulate::use_virtualenv("r-reticulate", required = TRUE)

#reticulate::py_discover_config()
#reticulate::py_config()

reticulate::py_install("Cython")
reticulate::py_install("sympy")
symengine:::symengine_py_install(ref = "Marlin-Na/symengine.py@pycapsule")

s4basic_as_py <- function(x, convert=FALSE) {
    symengine_py_module <- reticulate::import("symengine", convert=FALSE)
    ## Convert external pointer to pycapsule
    cap <- reticulate::r_to_py(x@ptr, convert=convert)
    ## Convert to symengine py object
    ans <- symengine_py_module$lib$symengine_wrapper$sympify_pycapsule(cap)
    ans
}

s4basic_from_py <- function(x) {
    symengine_py_module <- reticulate::import("symengine", convert=FALSE)
    ans <- symengine:::s4basic()
    symengine_py_module$lib$symengine_wrapper$assign_to_pycapsule(
        reticulate::r_to_py(ans@ptr), x)
    ans
}

r_to_py.Basic <- function(x, convert=FALSE) {
    s4basic_as_py(x, convert)
}

py_to_r.symengine.lib.symengine_wrapper.Basic <- function(x) {
    s4basic_from_py(x)
}

py_to_r.sympy.core.basic.Basic <- function(x) {
    s4basic_from_py(x)
}


x <- S("x")

sympy <- reticulate::import("sympy")
sympy$integrate(x^2L/2L)
sympy$integrate(x^2L/2L, tuple(x, 1L, 2L))

