"""
    @latexify expression

Create `LaTeXString` representing `expression`.
Variables and expressions can be interpolated with `\$`.

# Examples
```julia-repl
julia> @latexify x^2 + 3/2
L"\$x^{2} + \\frac{3}{2}\$"

julia> @latexify x^2 + \$(3/2)
L"\$x^{2} + 1.5\$"
```

See also [`latexify`](@ref), [`@latexrun`](@ref), [`@latexdefine`](@ref).
"""
macro latexify(expr)
    return esc(:(latexify($(Meta.quot(expr)))))
end

"""
    @latexrun expression

Latexify and evaluate `expression`. Useful for expressions with side effects, like assignments.

# Examples
```julia-repl
julia> @latexrun y = 3/2 + \$(3/2)
L"\$y = \\frac{3}{2} + 1.5\$"

julia> y
3.0
```
See also [`@latexify`](@ref), [`@latexdefine`](@ref).
"""
macro latexrun(expr)
    return esc(
        Expr(
            :block,
            postwalk(expr) do ex
                if ex isa Expr && ex.head == :$
                    return ex.args[1]
                end
                return ex
            end,
            :(latexify($(Meta.quot(expr)))),
        )
    )
end

"""
    @latexdefine expression

Latexify `expression`, followed by an equals sign and the return value of its evaluation.
Any side effects of the expression, like assignments, are evaluated as well.

# Examples
```julia-repl
julia> @latexdefine y = 3/2 + \$(3/2)
L"\$y = \\frac{3}{2} + 1.5 = 3.0\$"

julia> y
3.0
```
See also [`@latexify`](@ref), [`@latexrun`](@ref).
"""
macro latexdefine(expr)
    return esc(
        :(latexify(
            Expr(
                 :(=),
                $(Meta.quot(expr)),
                $(postwalk(expr) do ex
                    if ex isa Expr && ex.head == :$
                        return ex.args[1]
                    end
                    return ex
                end),
            )
        )),
    )
end
