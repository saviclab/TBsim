#include <algorithm>
#include <random>

#include "statFunctions.h"

// define random number generator
namespace random2
{
    std::random_device rd2;
    std::mt19937 engine2(rd2());
}

//=================================================================
// sum vector v from index i to j
// note it includes index j
// no checking of index values performed
//=================================================================
double sumVec(VEC& v, int i, int j)
{
    double temp(0.0);
    for (int n=i; n<(j+1); n++){
        temp += v[n];
    }
    return temp;
}

//=================================================================
// Element-wise multiplication of two vectors a and b
// return result in third vector c
//=================================================================
void multTwoVectors (VEC& a, VEC& b, VEC& c)
{
#pragma omp parallel for
    for (int i=0; i<a.size(); i++){
        c[i] = a[i] * b[i];
    }
}

//=================================================================
// Find maximum of vector of <double>, from start to stop included
//=================================================================
double vectorMax(VEC& V, int start, int stop)
{
    VEC::const_iterator it_start = V.begin() + start;
    VEC::const_iterator it_stop  = V.begin() + stop + 1;
    VEC::const_iterator it_max;
    it_max = std::max_element(it_start, it_stop);
    return *it_max;
}

//=================================================================
// Find minimum of vector of <double>, from start to stop included
//=================================================================
double vectorMin(VEC& V, int start, int stop)
{
    VEC::const_iterator it_start = V.begin() + start;
    VEC::const_iterator it_stop  = V.begin() + stop + 1;
    VEC::const_iterator it_min;
    it_min = std::min_element(it_start, it_stop);
    return *it_min;
}

//=================================================================
// Calculate average of vector of type <double>
// from start to stop (INCLUDING item=stop)
// if sum error condition then return 0
//=================================================================
double vectorAvg(VEC& V, int start, int stop){
    double sum(0.0);
    double avg(0.0);
    int items(0);

    VEC::const_iterator it_start = V.begin() + start;
    VEC::const_iterator it_stop  = V.begin() + stop + 1;
    sum = std::accumulate(it_start, it_stop, 0.0);
    items = stop-start+1;
    if (items>0){
        avg = sum/double(items);
    }
    else {
        avg = 0.0;
    }
    return avg;
}

//=================================================================
// FUNCTION: addVarianceLin
// Add variance to parameters using linear distribution
// xIn: input vector
// xOut: output vector
// N: length of vector
// s: variance of distribution [0..1]
//=================================================================
/*void addVarianceLin(VEC& xIn, VEC& xOut, int N, double s)
{
#pragma omp paralell for
    for (int i=0; i<N; i++) {
        xOut[i] = linDist(xIn[i]*(1.0 - s), xIn[i]*(1.0 + s));
   }
}
*/
//=================================================================
// FUNCTION: addVarianceNorm
// Add variation to input vector using normal distribution
// xIn: input vector
// xOut: output vector
// N: length of vector
// s: variance of distribution [0..1]
// Note: distribution scaled to: 0.1 * mu and 3 * mu
//=================================================================
/*
void addVarianceNorm(VEC& xIn, VEC& xOut, int N, double s)
{
#pragma omp paralell for
    for (int i=0; i<N; i++) {
        xOut[i] = xIn[i] * ( 1.0 + normDist(0.0, s, -0.9, 2.0));
    }
}
*/
//=================================================================
// Multiply vector with scalar, and return result in SAME vector
//=================================================================
/*
void multVector(VEC& a, double x)
{
#pragma omp paralell for
    for (int i=0; i<a.size(); i++){
        a[i] *= x;
    }
}
*/
//=================================================================
//multiply vector with scalar, and return result in SECOND vector
//=================================================================
/*
void multVectorAlt(VEC& V1, VEC& V2, double x)
{
#pragma omp paralell for
    for (int i=0; i<V1.size(); i++){
        V2[i] = V1[i] * x;
    }
}
*/
//=================================================================
// Adjust vector to have slower rate of decline over time
// later on this method may be good to parameterize for
// to allow for different decay rates
//=================================================================
void decayVector(VEC& V1, double decayFactor)
{
    VEC V2(V1.size(), 0.0);
    V2[0] = V1[0];
    // decayFactor is in range from 0.0+ to 1
    // if = 0 then no decline at all
    // if = 1 then same decline as input concentration
    // (if > 1 then declining faster, nonsensical)
    for (int i=1; i<int(V1.size()); i++) {
        // declining phase
        if (V1[i]<=V1[i-1]) {
            V2[i] = std::max(0.0, V2[i-1] - std::abs(V2[i-1] - V1[i]) * decayFactor);
        }
        else {
            // growing phase
            V2[i] = V1[i];
        }
    }

    //copy back results
    V1 = V2;
}

//=================================================================
// Generate random value from linear distribution
// between min mi and max ma, (ma > mi)
//=================================================================

double linDist(double mi, double ma)
{
    std::uniform_real_distribution<double> udis(mi, ma);
    double su;
    su = udis(random2::engine2);

    return su;
}
//=================================================================
// Generate normal distributed value with mean m and stdv s
// Resampling if outside of min mi or max ma, with ma > mi
// note - may be used in different context in different classes
//=================================================================
double normDist(double m, double s, double mi, double ma)
{
    std::normal_distribution<double> ndist(0.0, 1.0);
    double su = mi - 1.0;  // used as start value to enter while loop

    while ((su<mi) || (su>ma)){
          su = m + s * ndist(random2::engine2);
    }
    return su;
}
