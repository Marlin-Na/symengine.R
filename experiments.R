
library(reticulate)
library(symengine)

reticulate::use_python(Sys.which("python3"), required = TRUE)

x <- S("x")

s4basic_as_py <- function(x) {
    ## Convert external pointer to pycapsule
    cap <- reticulate::r_to_py(x@ptr)

    ## Extract pointer from capsule
    ctypes <- reticulate::import("ctypes", convert=FALSE)
    PyCapsule_GetPointer <- ctypes$pythonapi$PyCapsule_GetPointer
    PyCapsule_GetPointer$restype <- ctypes$c_void_p
    PyCapsule_GetPointer$argtypes <- list(ctypes$py_object, ctypes$c_char_p)
    handle <- PyCapsule_GetPointer(cap, NULL)
    handle # python int

    ## Cast into ctypes pointer
    py_basic_voidp <- ctypes$cast(handle, ctypes$c_void_p)
    
    ## TODO
}

symengine_dll <- ctypes$cdll$LoadLibrary("symengine.so")
symengine_dll$basic_abs
symengine_dll$basic_new_stack

symengine_py <- reticulate::import("symengine", convert=FALSE)

