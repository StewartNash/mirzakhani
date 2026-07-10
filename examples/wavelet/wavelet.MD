# Wavelet

## Introduction

This educational repository contains a MATLAB implementation of the wavelet transform. It is taken from *An Introduction to Random Vibrations, Spectral and Wavelet Analysis* by D. E. Newland.

## Functions

There are ten MATLAB functions

1. wavedn
2. iwavedn
3. displayn
4. mapdn
5. wave2dn
6. iwave2dn
7. dcoeffs
8. hwtdn
9. ihwtdn
10. hmapdn

A description of each of these functions follows.

### wavedn

wavedn(f, N) returns an array whose elements are the wavelet transform of the sequence of elements in f. The analyzing wavelet has N coefficients where N is even.

### iwavedn

iwavedn(a, N) is the inverse transform of wavedn(f, N). iwavedn(a, N) returns the sequence of elements f which result from the transform whose elements are 'a' and has length N.

### displayn

displayn(f, N) (uses a=wavedn(f, N) to) computes the wavelet transform of 'f' which is a sequence of length 2^n; then iwavedn(b, N) is used repeatedly to generate successive rows of the matrix A which has n+1 rows and 2^n columns. Row 1 is the level -1 reconstruction (always constant), row 2 is the level 0 reconstruction, row 3 the level 1 reconstruction and so on. All the rows of A added together regenerate the original signal f. The results are plotted for examination.

