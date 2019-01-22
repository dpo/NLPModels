#Problem 6 in the Hock-Schittkowski suite
function hs6_autodiff()

  x0 = [-1.2; 1.0]
  f(x) = (1 - x[1])^2
  c(x) = [10 * (x[2] - x[1]^2)]
  lcon = [0.0]
  ucon = [0.0]

  return ADNLPModel(f, x0, c=c, lcon=lcon, ucon=ucon)
end

function hs6_simple()

  x0 = [-1.2; 1.0]
  f(x) = (1 - x[1])^2
  g(x) = [-2*(1 - x[1]); 0.0]
  g!(x, gx) = begin
    gx[1] = -2*(1 - x[1])
    gx[2] = 0.0
    return gx
  end

  c(x) = [10 * (x[2] - x[1]^2)]
  c!(x, cx) = begin cx[:] = c(x) end
  J(x) = [-20*x[1]  10]
  Jc(x) = ([1,1], [1,2], [-20*x[1], 10])
  Jp(x, v) = J(x) * v
  Jp!(x, v, w) = begin w[:] = J(x) * v end
  Jtp(x, v) = J(x)' * v
  Jtp!(x, v, w) = begin w[:] = J(x)' * v end

  H(x) = [2.0 0.0; 0.0 0.0]
  C(x, y) = [-20 0; 0 0]*y[1]
  W(x; obj_weight=1.0, y=zeros(1)) = tril(obj_weight*H(x) + C(x,y))
  Wcoord(x; obj_weight=1.0, y=zeros(1)) = begin
    Wx = W(x; obj_weight=obj_weight, y=y)
    return [1, 2, 2], [1, 1, 2], [Wx[1,1], Wx[2,1], Wx[2,2]]
  end
  Wp(x, v; obj_weight=1.0, y=zeros(1)) = (obj_weight*H(x) + C(x,y))*v
  Wp!(x, v, Wv; obj_weight=1.0, y=zeros(1)) = begin Wv[:] = (obj_weight*H(x) + C(x,y))*v end
  lcon = [0.0]
  ucon = [0.0]

  return SimpleNLPModel(f, x0, g=g, g! =g!, c=c, c! =c!, J=J, Jcoord=Jc, Jp=Jp,
      Jp! =Jp!, Jtp=Jtp, Jtp! =Jtp!, H=W, Hcoord=Wcoord, Hp=Wp, Hp! =Wp!,
      lcon=lcon, ucon=ucon, nnzj=2, nnzh=3)
end
