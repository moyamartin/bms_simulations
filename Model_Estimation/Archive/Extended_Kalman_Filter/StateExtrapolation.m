function [x,y] = StateExtrapolation( A, B, C, D, x, u, Ts)

% [x,y] = StateExtrapolation( A, B, C, D, x, u, Ts)
%
% x = x + (A*x + B*u)*Ts;
% y = C*x + D*u;
%


x = x + (A*x + B*u)*Ts;
y = C*x + D*u;

end