function G = customkernel(U,V)
% Custom kernel function for use with SVM
% it produces ratios of the different frequencies

G = [U(1)/V(1) U(2)/V(2)];

end
