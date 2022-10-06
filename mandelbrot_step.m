function [z,kz] = mandelbrot_step(z,kz,z0,d,p)
% MANDELBROT_STEP  Take a single step of the Mandelbrot iteration.
% [z,kz] = mandelbrot_step(z,kz,z0,d)

%   Copyright 2014 Cleve Moler
%   Copyright 2014 The MathWorks, Inc.
   z = z.^p + z0;
%  z = z0.^z;
%   p=p+1;
   j = (abs(z) < 2);
   kz(j) = d;
