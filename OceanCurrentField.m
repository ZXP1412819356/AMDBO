function V = OceanCurrentField(pos,t,P)
% =========================================================================
% Three-dimensional time-varying nonuniform ocean-current field.
%
% This is a simulation current field, not a measured field from a specific
% sea area. U0 should be varied in the current-speed sensitivity experiment.
% =========================================================================

x = pos(:,1);
y = pos(:,2);
z = pos(:,3);

U0 = P.current.U0;
Tc = P.current.period;

temporal = ...
    1 + 0.20*sin(2*pi*t/Tc);

u = U0 .* temporal .* ...
    (1 - 0.25*z/P.Lz) .* ...
    (1 + 0.12*cos(2*pi*y/P.Ly));

v = P.current.crossRatio*U0 .* ...
    sin(2*pi*x/P.Lx + 2*pi*t/Tc) .* ...
    (1 - 0.15*z/P.Lz);

w = P.current.verticalRatio*U0 .* ...
    sin(pi*z/P.Lz) .* ...
    cos(2*pi*y/P.Ly - 2*pi*t/Tc);

V = [u,v,w];

end
