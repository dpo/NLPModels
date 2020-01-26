export NLSMeta

# The problem is
#
#    min    ¹/₂‖F(x)‖²
#
# where F:ℜⁿ→ℜᵐ. `n` = `nvar`, `m` = `nequ`.
#
# TODO: Extend

struct NLSMeta
  nequ :: Int
  nvar :: Int
  x0 :: Vector
  nnzj :: Int  # Number of elements needed to store the nonzeros of the Jacobian of the residual
  nnzh :: Int  # Number of elements needed to store the nonzeros of the sum of Hessians of the residuals
end

function NLSMeta(nequ :: Int, nvar :: Int;
                 x0 :: AbstractVector = zeros(nvar),
                 nnzj=nequ * nvar,
                 nnzh=div(nvar * (nvar + 1), 2)
                )
  nnzj = max(0, nnzj)
  nnzh = max(0, nnzh)
  return NLSMeta(nequ, nvar, x0, nnzj, nnzh)
end

const nls_fields = Dict(Symbol("nls_$x") => x for x in fieldnames(NLSMeta))

function Base.getproperty(nls :: AbstractNLSModel, f :: Symbol)
  if f in keys(nls_fields)
    return getproperty(nls.nls_meta, nls_fields[f])
  end
  if f in fieldnames(NLPModelMeta)
    return getproperty(nls.meta, f)
  end
  return getfield(nls, f)
end
