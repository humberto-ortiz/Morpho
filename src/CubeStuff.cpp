#include <RcppArmadillo.h>
#include "doozers.h"
#include "addCube.h"
using namespace Rcpp;
using namespace std;
using namespace arma;

RcppExport SEXP addo(SEXP array_) {
  
  NumericVector vecArray(array_);
  IntegerVector arrayDims = vecArray.attr("dim");
  cube myCube(vecArray.begin(), arrayDims[0],arrayDims[1], arrayDims[2], false);
  mat out = Morpho::IOCube<double>::addCube(myCube);
  return wrap(out);

}

RcppExport SEXP scaleproc(SEXP array_) {
  typedef unsigned int uint;
  vec h; mat U; mat V;
  NumericVector vecArray(array_);
  IntegerVector arrayDims = vecArray.attr("dim");
  cube myCube(vecArray.begin(), arrayDims[0],arrayDims[1], arrayDims[2], false);
  unsigned int n = myCube.n_slices;
  vec aa(n);
  mat omat(n,arrayDims[0]*arrayDims[1]);
  for (unsigned int i = 0; i < n; i++) {
    aa(i) = accu(myCube.slice(i) % myCube.slice(i));
    colvec tmp = vectorise(myCube.slice(i));
    omat.row(i) = conv_to<rowvec>::from(tmp);
  }
  mat omatorig = omat;
  uint nn = n;
  uint kk = omat.n_cols;
  double aasum = sum(aa);
  double df = nn;
  mat Lmat;
  df = (df-1)/df;
  vec qq(nn);
  if (nn > kk) {
    for (uint i = 0; i < nn; i++) {
      qq(i) = var(omat.row(i),0)*df;
      omat.row(i) -= mean(omat.row(i));
    }
    omat = diagmat(sqrt(1/qq))*omat;
    df = kk;
    Lmat = omat.t() * (omat/df);
    vec lambda;
    
    eig_sym(lambda, U, Lmat);
    uint nlam = lambda.n_elem;
    uvec usort(nlam);
    for (uint i = 0; i < nlam;i++)
      usort(i) = nlam - 1 - i;
      
    U = U.cols(usort);
    lambda = lambda(usort);
    V = omat * U;
    vec vv(kk);
    for (uint i=0; i < kk;i++) {
      vv(i) = sqrt(dot(V.col(i), V.col(i)));
      V.col(i) = V.col(i)/vv(i);
    }
    vec delta = sqrt(abs(lambda/df)) % vv;
    uvec od = sort_index(delta, "descend");
    //delta = delta(od);   
    //V = V.cols(od);
    h = abs(sqrt(aasum/aa) % V.col(od(0)));
    Rprintf("%f\n",aa(0));
  } else {
    mat zz = cor(omatorig.t());
    vec eigval;
    mat eigvec;
    unsigned int maxval = eigval.n_cols;
    eig_sym( eigval, eigvec, zz);
    h = abs(sqrt(aasum/aa) % eigvec.col(maxval));
    
  }
  return wrap(h);
}