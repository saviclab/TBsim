#ifndef STATFUNCTIONS_H
#define STATFUNCTIONS_H

#include <vector>
//#include <omp.h>

#include "Global.h"

double sumVec(VEC&, int, int);

double linDist(double, double);

double normDist (double, double, double, double);

//void addVarianceLin (VEC&, VEC&, int, double);
inline void addVarianceLin(VEC& xIn, VEC& xOut, int N, double s)
{
#pragma omp paralell for
    for (int i=0; i<N; i++) {
        xOut[i] = linDist(xIn[i]*(1.0 - s), xIn[i]*(1.0 + s));
   }
}

//void addVarianceNorm(VEC&, VEC&, int, double);
inline void addVarianceNorm(VEC& xIn, VEC& xOut, int N, double s)
{
#pragma omp paralell for
    for (int i=0; i<N; i++) {
        xOut[i] = xIn[i] * ( 1.0 + normDist(0.0, s, -0.9, 2.0));
    }
}

//void multVector(VEC&, double);
inline void multVector(VEC& a, double x)
{
#pragma omp paralell for
    for (int i=0; i<a.size(); i++){
        a[i] *= x;
    }
}

//void multVectorAlt(VEC&, VEC&, double);
inline void multVectorAlt(VEC& V1, VEC& V2, double x)
{
#pragma omp paralell for
    for (int i=0; i<V1.size(); i++){
        V2[i] = V1[i] * x;
    }
}

void decayVector(VEC&, double);

double vectorMin(VEC&, int, int);

double vectorMax(VEC&, int, int);

double vectorAvg(VEC&, int, int);

void multTwoVectors (VEC&, VEC&, VEC&);

#endif // STATFUNCTIONS_H
