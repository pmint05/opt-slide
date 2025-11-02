#import "@preview/lovelace:0.3.0": *
#import "@preview/touying:0.5.3": *
#import "stargazer.typ": *
#import "@preview/fletcher:0.5.3" as fletcher: diagram, edge, node

#import "@preview/numbly:0.1.0": numbly

#show: stargazer-theme.with(
  aspect-ratio: "16-9",
  config-info(
    // subtitle: [vehicle routing problem with time windows],
    // author: [Huỳnh Tiến Dũng],
    // instructor: [TS. Hoàng Thị Điệp],
    // date: "17/12/2024",
    // institution: [Trường Đại học Công Nghệ - ĐHQGHN],
  ),
)
#set text(font: "New Computer Modern", lang: "vi")
#set heading(numbering: numbly("{1}.", default: "1.1."))
#set par(justify: true)
#show figure.caption: set text(17pt)

#slide(navigation: none, progress-bar: false, self => [
  #align(center, text(24pt, upper(strong("Sử dụng thuật toán di truyền\ngiải bài toán định tuyến xe\nvới ràng buộc thời gian")))),
  #align(center, [
    Hybrid Genetic Search for the Vehicle Routing\
    Problem with Time Windows:\
    a High-Performance Implementation
  ]),
  #align(center, [
    *Wouter Kool*
  ])
])

#outline-slide(title: "Mục lục")

// == Outline <touying:hidden>

// #components.adaptive-columns(outline(title: none, indent: 1em))


= Giới thiệu
== Bài toán <touying:hidden>

#align(center)[
  #image("images/vrptw-1.svg", width: 90%)
]
== Các nghiên cứu liên quan <touying:hidden>
#align(center)[
  #v(0.5cm)
  #image("images/vrptw-2.png", width: 65%)
]

= Thuật toán
== Hàm mục tiêu <touying:hidden>

#grid(
  columns: (45%, auto),
  align(left)[
    #image("images/vrptw-3.svg", width: 80%)
  ],
  align(left)[
    #set par(leading: 1.6em)
    $r = (sigma_0^r, sigma_1^r, dots, sigma_n^r, sigma_(n+1)^r)$\
    $bold(t)^r = (t_0^r, ..., t_(n_r+1)^r)$\
    $"tw"_(i,i+1) = max(t_i^r + tau_(sigma_i^r) + delta_(sigma_i^r sigma_(i+1)^r) - t_(i+1)^r, 0)$\
  ],
)

== Hàm mục tiêu <touying:hidden>
#grid(
  columns: (45%, auto),
  align(left)[
    #image("images/vrptw-3.svg", width: 80%)
  ],
  align(left)[
    #set par(leading: 1.6em)
    $q(r) = sum_(i=1)^(n_r) q_(sigma_i^r)$\
    $c(r) = sum_(i=0)^(n_r) c_(sigma_i^r sigma_(i+1)^r)$\
    $"tw"(r) = sum_(i=0)^(n_r) "tw"_(i,i+1)$\
    $phi(r) = c_r + omega^Q max(0, q(r)-Q) + omega^("TW") "tw"(r)$
  ],
)

== Tổng quan <touying:hidden>

#align(center)[
  #image("images/vrptw-5.svg", width: 98%)
]

== Heuristic kiến trúc <touying:hidden>

#[
  #set text(size: 18pt)
  #figure(
    kind: "algorithm",
    supplement: [Algorithm],

    pseudocode-list(
      hooks: .5em,
      booktabs: true,
      numbered-title: [Nearest/farthest algorithm #h(1fr)],
    )[
      + $S = {1, 2, 3, ..., n}$
      + $"solutions" <- []$
      + *for* $t = 1$ to $m$:
        + $"customers" <- []$
        + $i <- "nearest/farthest customers from depot" in S$
        + *while* S is not empty:
          + $j <- &a "customer" in S\ &"that can be add to `customers` and causes least detour distance"$
          + *if* $j$ not exists:
            + break
          + add $j$ to customers, remove $j$ from $S$

        + add customers to solutions
    ],
  )
]

== Sweep <touying:hidden>

- Sắp xếp các khách hàng theo góc giữa nó và điểm xuất phát.
- Thêm các khách hàng cho đến khi quá trọng tải.
- Với mỗi chuyến đi:
  - Sắp xếp các khách hàng có time window ngắn (< 50%) tăng dần theo $l_i$
  - Chèn lại các khách hàng có time window dài sao cho khoảng cách tăng là ít nhất.

== Lai tạo <touying:hidden>

#align(center)[
  #image("images/vrptw-4.svg", width: 100%)
]

== Đánh giá độ phù hợp <touying:hidden>
#let eqz = align(center)[#block(
  stroke: 1pt + rgb("#888"),
  inset: (x: 12pt, y: 10pt),
)[$ f_P (S) = f_P^(phi) (S) + (1 - n^("ELITE")/(|P|)) f_P^("DIV")(S) $]]

#align(top)[
  #v(2cm)
  #eqz
  - $f_P^(phi) (S)$ là hạng của lời giải $S$, sắp xếp theo chất lượng lời giải.
]

#pagebreak()
#align(top)[
  #v(2cm)
  #eqz
  - $f_P^("DIV")(S)$ là hạng của lời giải $S$, khi xét khả năng mở rộng\
  - $Delta(S) = 1/(n^("CLOSEST")) sum_(S_2) d(S, S_2)$
  #v(0.3cm)
  #align(center)[
    #image("images/vrptw-6.svg", width: 50%)
  ]
]

#pagebreak()

#align(top)[
  #v(2cm)
  #eqz
  - Hệ số $(1 - n^("ELITE")/(|P|))$ được sử dụng để đảm bảo ta vẫn giữ lại được $n^("ELITE")$ lời giải chất lượng tốt nhất trong suốt quá trình tìm kiếm
]
#pagebreak()


== Crossover operator <touying:hidden>
#align(center, [
  #image("images/vrptw-7.svg", width: 80%)
])

== Thuật toán SPLIT <touying:hidden>

#[
  #set text(size: 18pt)
  #figure(
    kind: "algorithm",
    supplement: [Algorithm],

    pseudocode-list(
      hooks: .5em,
      booktabs: true,
      numbered-title: [Classical Split Algorithm: Fleet limited to $m$ vehicles #h(1fr)],
    )[
      + *for* $k <- 1$ *to* $m$ *do*
        + *for* $t <- 1$ *to* $n$ *do*
          + $f[k][t] <- infinity;$
      + $f[0][0] <- 0$
      + *for* $k <- 1$ *to* $m$ *do*
        + *for* $i <- 0$ *to* $n$ *do*
          + $j <- i + 1;$
          + *while* $j <= n$ *and* $"canAdd"(j)$ *do*
            + *if* $f[k][j] > f[k - 1][i] + "cost"(i + 1, j)$ *then*
              + $f[k][j] <- f[k - 1][i] + "cost"(i + 1, j);$
              + $"pred"[k][j] <- i$
            + $j <- j + 1;$
    ],
  )
]
#pagebreak()
#align(
  top,
  [
    #set text(size: 17pt)
    #align(center)[#block(stroke: 1pt + rgb("#888"), inset: (x: 20pt, y: 8pt))[
      $
        &italic("dominates")(i, j) eq.triple cases(p[i] + d_(0, i+1) - D[i+1] + alpha times (Q[j] - Q[i])<=p[j] + d_(0, j+1) - D[j+1] &"  if" i<j, p[i] + d_(0, i+1) - D[i+1] <= p[j] + d_(0, j+1) - D[j+1] &"  if" i>j)
      $
    ]]
    #grid(
      columns: 2,
      gutter: 0.6em,
      align: left + top,
      align(top)[
        Trong đó:
      ],
      [
        #set par(leading: 1.4em)
        - $c(i, j) = d_(0, i+1) + D[j] - D[i+1] + d_(j, 0) + alpha times max{Q[j] - Q[i] - Q, 0}$\
        - $D[i] = sum_(k = 1)^(i-1) d_(k, k+1)$\
        - $Q[i] = sum_(k = 1)^(i) q_k$\
      ],
    )
  ],
)
#place(
  bottom + right,
  dy: -0.3cm,
  [
    #set text(size: 12.5pt)
    #figure(
      kind: "algorithm",
      supplement: [Algorithm],

      pseudocode-list(
        hooks: .5em,
        booktabs: true,
        numbered-title: [Linear Split],
      )[
        + $p[0] <- 0$
        + $S <- (0)$
        + *for* $t <- 0$ *to* $n$ *do*
          + $p[t] <- p[italic("front")] + f(italic("front"), t)$
          + $italic("pred")[t] <- italic("front")$
          + *if* $t < n$ *then*
            + *if not* $italic("dominates")(italic("back"), t)$ *then*
              + *while* $|S| > 0$ *and* $italic("dominates")(italic("back"), t)$ *do*
                + $italic("popBack")()$
              + $italic("pushBack")(t)$
            + *while* $|S| > 1$ *and* $p[italic("front")] + f(italic("front"), t + 1) >= p[italic("front2")] + f(italic("front2"), t + 1)$
              + $italic("popFront")()$
      ],
    )
  ],
)


== Selective Route Exchange (SREX) <touying:hidden>

#image(
  "images/vrptw-8.svg",
  width: 100%,
)

== Local Search <touying:hidden>

#align(center)[
  #image(
    "images/vrptw-10.svg",
    width: 60%,
  )
]
#align(center)[
  #image(
    "images/vrptw-11.svg",
    width: 80%,
  )
]
#pagebreak()

Với mỗi khách hàng $i$, ta định nghĩa một tập $Gamma(i)$ gồm $Gamma$ khách hàng gần $i$ nhất theo độ đo tương quan dưới đây:
#align(center)[#block(
  stroke: 1pt + rgb("#888"),
  inset: (x: 12pt, y: 12pt),
)[
  $
    gamma(i, j) = c_(i j) + gamma^("WT") max(e_j - tau_i - delta_(i j) - l_i, 0) + gamma^("TW") max(e_i + tau_i + delta_(i j) - l_j, 0)
  $
]]
#align(center)[
  #image("/images/vrptw-9.svg", width: 90%)

]

== Lựa chọn tham số <touying:hidden>


_Ban đầu:_ $display(cases(omega^Q &<- 1, omega^"TW" &<- 1))$

_Sau 100 lần lặp:_ $omega^Q\, omega^"TW" "sẽ" display(cases("tăng" 20% "nếu" < 15\% "lời giải hợp lệ", "giảm" 15\% "nếu" > 25\% "lời giải hợp lệ", "tăng lên" 100\% "nếu không tìm được lời giải hợp lệ"))$

#pagebreak()

Các hằng số cố định: $n^("ELITE")=4$, $n^("CLOSEST")=5$, $lambda = 40$.

#let vv = $checkmark$
#let xx = $crossmark$

#figure(
  table(
    columns: (auto, 36%, auto),
    align: left + horizon,
    inset: (x: 12pt, y: 10pt),
    table.header(
      table.cell(align: center, [Có hành trình dài\ (> 25 khách)]),
      table.cell(align: center, [Có khách hàng với ràng buộc thời gian rộng (> 70%)]),
      table.cell(align: center, [Hành động]),
    ),

    table.cell(align: center, [#vv]),
    [],
    [$theta = 15%, mu = 25, Gamma = 40$ tăng $mu$ và $Gamma$ lên 5 sau 10000 lần lặp],
    table.cell(align: center, [#xx]),
    table.cell(align: center, [#xx]),
    [$theta = 100%, mu = 25, Gamma = 40$ tăng $mu$ và $Gamma$ lên 5 sau 10000 lần lặp],
    table.cell(align: center, [#xx]),
    table.cell(align: center, [#vv]),
    [$theta = 100%, mu = 25, Gamma = 20$ tăng $mu$ và $Gamma$ lên 5 sau 20000 lần lặp],
  ),
)

Sau 10000 lần lặp mà không có cải tiến nào, ta reset lại quần thể và vẫn giữ nguyên tham số cũ.


== Lược đồ thuật toán <touying:hidden>

#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  block(
    stroke: 1pt + rgb("#888"),
    inset: (x: 12pt),
    width: 90%,
  )[
    #set text(18pt)
    #pseudocode-list(
      hooks: .5em,
    )[
      + Initialize population;
      + *while* number of iterations without improvement $< italic("It")_("NI")$ and time $< T_"MAX"$ *do*
        + Select parent solutions $P_1$ and $P_2$;
        + Apply crossover operators on $P_1$ and $P_2$ to generate an offspring $C$;
        + Educate offspring $C$ by local search;
        + Insert $C$ into respective subpopulation;
        + *if* $C$ is infeasible *then*
          + With $50\%$ probability, repair $C$ (local search) and insert it into respective subpopulation;
        + *if* maximum subpopulation size reached *then*
          + Select survivors;
        + Adjust penalty coefficients for infeasibility;
      + Return best feasible solution;
    ]

  ],
)

= Kết quả
== Kết quả <touying:hidden>
Thuật toán được tác giả chạy thử nghiệm trên bộ dữ liệu của Solomon và Homberger #footnote("https://www.sintef.no/projectweb/top/vrptw/"), và cho ra kết quả như sau:
#image("/images/result.png")
