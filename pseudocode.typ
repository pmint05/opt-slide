#import "@preview/lovelace:0.3.0": *

#figure(
  kind: "algorithm",
  supplement: [Algorithm],

  pseudocode-list(
    width: 100%,
    hooks: .5em,
    booktabs: true,
    numbered-title: [Class Split Algorithm: Fleet limited to $m$ vehicles #h(1fr)],
  )[
    + *for* $k <- 1$ *_to_* $m$ *do*
      + *for* $t <- 1$ *_to_* $n$ *do*
        + $f[k][t] <- infinity;$
    + $f[0][0] <- 0$
    + *for* $k <- 1$ *_to_* $m$ *do*
      + *for* $i <- 0$ *_to_* $n$ *do*
        + $j <- i + 1;$
        + *while* $j <= n$ *and* $"canAdd"(j)$ *do*
          + *if* $f[k][j] > f[k - 1][i] + "cost"(i + 1, j)$ *then*
            + $f[k][j] <- f[k - 1][i] + "cost"(i + 1, j);$
            + $"pred"[k][j] <- i$
          + $j <- j + 1;$
  ],
) <cool>

See @cool for details on how to do something cool.


#import "@preview/algorithmic:1.0.6"
#import algorithmic: algorithm-figure, style-algorithm
#show: style-algorithm.with(
  // breakable: false,
  // caption-style: text,
  placement: none,
  scope: "column",
)
#algorithm-figure(
  [Class Split Algorithm: Fleet limited to $m$ vehicles],
  vstroke: .5pt + luma(200),
  // supplement: [*Algorithm*],
  {
    import algorithmic: *
    {
      For($k <- 1$, {
        For($t <- 1$, {
          $f[k][t] <- infinity;$
        })
      })
      Assign[$f[0][0]$][0;]
      For($k <- 1$, {
        For($i <- 0$, {
          Assign[$j$][$i + 1$]
          While($j <= n "and" "canAdd"(j)$, {
            If($f[k][j] > f[k - 1][i] + "cost"(i + 1, j)$, {
              Assign[$f[k][j]$][$f[k - 1][i] + "cost"(i + 1, j)$;]
              Assign[$"pred"[k][j]$][$i$;]
            })
            Assign[$j$][$j + 1$;]
          })
        })
      })
    }
  },
) <cool2>

See @cool2 for details on how to do something even cooler.
,
