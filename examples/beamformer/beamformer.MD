# Beamformer

## Joint Complex Gradient Transversal Filter

A joint complex gradient transversal filter (JCGTF or JCLMS transversal filter) can be conceived of as a complex-valued LMS adaptive FIR filter. The filter output is given as
```
\begin{equation}
	y(n)=\mathbf{w}^\dagger(n)\mathbf{x}(n)
\end{equation}
```
where x(n) is the complex input vector, w(n) is the complex coefficient vector and the dagger represents the Hermitian transpose. The error is given by
```
\begin{equation}
	e(n)=d(n)-y(n)
\end{equation}
```
and the coefficient update is
```
\begin{equation}
	w(n+1)=w(n)+\mu x(n)e^*(n)
\end{equation}
```
where d(n) is the desired signal, mu (micron) is the adaptation step size, and the asterisk denotes complex conjugation.

### Widely Linear (Augmented) JCLMS

The augmented complex LMS is given by
```
\begin{equation}
	y(n)=\mathbf{w}^\dagger\mathbf{x}(n)+\mathbf{g}^\dagger\mathbf{x}^*(n)
\end{equation}
```
for non-circular complex signals.
The update equations are then
```
\begin{align}
	\mathbf{w}(n+1)&=\mathbf{w}(n)+\mu\mathbf{x}(n)e^*(n)\\
	\mathbf{g}(n+1)&=\mathbf{g}(n)+\mu\mathbf{x}(n)e^*(n)
\end{align}
```

## Joint Complex Gradient Lattice (JCGL) Filter

A Joint Complex Gradient Lattice (JCGL) filter is the lattice counterpart of the JCLMS transversal filter. Rather than adapting FIR tap weights directly, it adapts a set of forward and backward prediction errors and reflection coefficients (PARCOR coefficients).

for an order-M complex lattice, define the forward prediction error as
```
\begin{equation}
	f_m(n)=f_{m-1}(n)-k_m(n)b_{m-1}(n-1)\quad,f_0(n)=x(n)
\end{equation}
```
and backward prediction error
```
\begin{equation}
	b_m(n)=b_{m-1}(n-1)-k_m^*(n)f_{m-1}(n)\quad,b_0(n)=x(n)
\end{equation}
```
The reflection coefficients k_m are adapted by a complex gradient rule. A commonly used JCGL adaptation is
```
\begin{equation}
	k_m(n+1)=k_m(n)+\mu f_m(n)b_m^*(n)
\end{equation}
```
where mu (micron) is the adaptation step size.

Many texts define the JCGL as an adaptive predictor rather than merely a lattice analyzer. In that case, the predictor output is
```
\begin{equation}
	\hat{x}(n)=-\sum_{m=1}^M{a_m(n)x(n-m)}
\end{equation}
```
and the final-stage forward error
```
\begin{equation}
	e(n)=f_M(n)
\end{equation}
```
becomes the prediction error.

Many systems extend the lattice with a ladder section
```
\begin{equation}
	y(n)=\sum_{m=0}^M{v_m(n)b_m(n)}
\end{equation}
```
where the lattice coefficents k_m perform whitening and ladder coefficinents v_m perform system identification.

This structure is the complex analog of the JCLSL.

## Joint Complex Least Squares Lattice (JCLSL) Filter

A joint complex least squares lattice (JCLSL) filter  combines
1. A complex lattice predictor (forward/backwared prediction errors)
2. A least-squares ladder section
3. Recursive estimation of reflection coefficients and ladder weights
It can be conceived of as the complex-valued adpative lattice equivalent of an RLS filter.

The structure of the fitler has the input x(n) go through a lattice and have b_m applied and go through a ladder to produce an output y(n). The final output is given by
```
\begin{equation}
	y(n)=\sum_{m=0}^M{v_m(n)b_m(n)}
\end{equation}
```
where v_m are the ladder coefficients.
