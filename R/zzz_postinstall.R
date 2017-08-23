cat("\n**********************************************************************\nCompiling TBsim executable:\n\n")
cat("\nNote: By default, /usr/bin/g++ is used as C++ compiler. If you want\nto use a different C++ compiler, please specify its location\nin the GCC_TBSIM environment variable, e.g.: \n\n    GCC_TBSIM=/usr/local/bin/gcc-7 R CMD INSTALL .\n")
cat("\n**********************************************************************\n\n")

cpp <- "/usr/bin/g++"
if(Sys.getenv("GCC_TBSIM") != "") {
  cpp <- Sys.getenv("GCC_TBSIM")
}
tb_compile(cpp = cpp)
