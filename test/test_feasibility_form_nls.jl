function test_nls_to_cons()
  @testset "Test FeasibilityFormNLS consistency" begin
    F1(x) = [x[1] - 1; 10 * (x[2] - x[1]^2)]
    F2(x) = [x[1] * x[2] * x[3] * x[4] * x[5] - 1]
    F3(x) = [x[1] + x[2] - 1; x[1]^2 + x[2]^2 - 2; x[1]^3 + x[2]^3 - 3]
    c1(x) = [sum(x); x[1] * x[2] - 2]
    for (F,n,ne) in [(F1,2,2), (F2,5,1), (F3,2,3)],
        (c,m) in [(x->zeros(0),0), (c1,2)]
      x0 = [-(1.0)^i for i = 1:n]
      nls = ADNLSModel(F, x0, ne, c=c, lcon=zeros(m), ucon=zeros(m))

      nlpcon = FeasibilityFormNLS(nls)
      adnlp = ADNLPModel(x->sum(x[n+1:end].^2) / 2, [x0; zeros(ne)],
                        c=x->[F(x[1:n]) - x[n+1:end]; c(x[1:n])],
                        lcon=zeros(ne+m), ucon=zeros(ne+m))
      consistent_functions([nlpcon; adnlp])

      adnls = ADNLSModel(x->x[n+1:end], [x0; zeros(ne)], ne,
                        c=x->[F(x[1:n]) - x[n+1:end]; c(x[1:n])],
                        lcon=zeros(ne+m), ucon=zeros(ne+m))
      consistent_functions([nlpcon; adnls])
      consistent_nls_functions([nlpcon; adnls])
    end
  end

  @testset "Test FeasibilityFormNLS with LLSModel" begin
    for n = [10; 30], ne = [10; 20; 30], m = [0; 20]
      for T in [#(rows,cols)->Matrix(1.0I, rows, cols) .+ 1,
                (rows,cols)->sparse(1.0I, rows, cols) .+ 1]
        A = T(ne,n)
        b = collect(1:ne)
        C = m > 0 ? T(m,n) : zeros(0,n)
        lls = LLSModel(A, b, C=C, lcon=zeros(m), ucon=zeros(m))
        nlpcon = FeasibilityFormNLS(lls)
        Ine = spdiagm(0 => ones(ne))
        lls2 = LLSModel([spzeros(ne,n) Ine], zeros(ne),
                        C=[A -Ine; C spzeros(m,ne)],
                        lcon=[b; zeros(m)], ucon=[b; zeros(m)])

        consistent_functions([nlpcon; lls2], exclude=[hess_coord])
        consistent_nls_functions([nlpcon; lls2])
      end
    end
  end
end

test_nls_to_cons()
