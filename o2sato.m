function o2sat = o2sato(T,S)
% Computes the oxygen saturation concentration at 1 atm total pressure
% in mol/m^3 given the temperature (t, in deg C) and the salinity (s,
% in permil). 
%
% FROM GARCIA AND GORDON (1992), LIMNOLOGY and OCEANOGRAPHY.
% THE FORMULA USED IS FROM PAGE 1310, EQUATION (8).
%
% *** NOTE: THE "A3*TS^2" TERM (IN THE PAPER) IS INCORRECT. ***
% *** IT SHOULDN'T BE THERE.                                ***
%
% o2sato IS DEFINED BETWEEN T(freezing) <= T <= 40(deg C) AND
% 0 permil <= S <= 42 permil
% 
% CHECK VALUE:  T = 10.0 deg C, S = 35.0 permil, 
% o2sato = 0.282015 mol/m^3
%
%
  A0 = 2.00907;
  A1 = 3.22014;
  A2 = 4.05010;
  A3 = 4.94457;
  A4 = -2.56847e-1;
  A5 =  3.88767;
  B0 = -6.24523e-3;
  B1 = -7.37614e-3;
  B2 = -1.03410e-2;
  B3 = -8.17083e-3;
  C0 = -4.88682e-7;
  TT  = 298.15-T;
  TK  = 273.15+T;
  TS  = log(TT./TK);
  TS2 = TS.^2;
  TS3 = TS.^3;
  TS4 = TS.^4;
  TS5 = TS.^5;
  CO  = A0 + A1*TS + A2*TS2 + A3*TS3 + A4*TS4 + A5*TS5+...
        S.*(B0 + B1*TS + B2*TS2 + B3*TS3)+...
        C0*(S.*S);
  o2sat = exp(CO);
  %
  %  Convert from ml/l to mmol/m^3
  %
  o2sat = (o2sat/22391.6)*1e6;


