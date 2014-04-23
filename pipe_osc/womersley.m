Rem = 2160.0
Reo = 610.0
alpha = 10.0
R = 0.5

nu  = 1/Rem;
omg = alpha^2 * nu / R^2;

r = linspace(0,R,100)/R;
uo = 1 - besselj(0, alpha*r*1i^(3/2)) / besselj(0,alpha*1i^(3/2));

%t = linspace(0,pi/2/omg,100);
%for j=1:100
%   plot(r, real(uo/1i*exp(1i*omg*t(j))));
%   pause(0.2)
%end


figure(2)
uc = 1 - besselj(0, 0) / besselj(0,alpha*1i^(3/2));
uc = real(uc*exp(1i*pi/2)/1i);
uo = uo*exp(1i*pi/2)/1i;
uo = real(uo)/uc * Reo/Rem;
us = 1 - r.^2;
um = us(1) + uo(1);
plot(r, uo, r, us, r, (us+uo))
legend('u_o','u_s','u')
