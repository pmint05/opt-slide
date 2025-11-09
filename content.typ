#import "@preview/lovelace:0.3.0": *
#set text(
  font: "New Computer Modern"
)

#set heading(numbering: "1.1.")

= Giới thiệu

Bài báo giới thiệu một cách triển khai thuật toán Hybrid Genetic Search (HGS) cho bài toán Vehicle Routing Problem with Time Windows (VRPTW) (VRPTW). Dựa trên phiên bản HGS-CVRP, nhóm tác giả đã mở rộng để xử lý các ràng buộc thời gian, bổ sung thêm một số operator, đồng thời điều chỉnh các tham số và tối ưu hiệu năng thực thi.

Đây không phải là một công trình được công bố trên tạp chí học thuật chính quy, mà là một bản tổng hợp và cải tiến từ các nghiên cứu trước đó. Các thuật toán được triển khai và thử nghiệm trên bộ dữ liệu VRPTW của cuộc thi DIMACS lần thứ 12, và bộ giải này đạt hạng nhất trong giai đoạn đầu của hạng mục VRPTW.



== Bài toán

Cho $G=(V,E)$ là một đồ thị đầy đủ có hướng. 

Đỉnh $v_0 in V$ thể hiện điểm tập kết, nơi tập hợp $m$ xe với sức chứa $Q$. Còn lại các đỉnh $v_i in V^(C S T)$ với $V^(C S T) = V \\ {v_0}$ với $i in [1, n]$ thể hiện các khách hàng cần được phục vụ. Mỗi khách hàng có nhu cầu không âm $q_i$, thời gian cần để phục vụ $tau_i$, và khoảng thời gian mà xe được phép phục vụ là $[e_i, l_i]$

Cạnh $(i, j) in E$ thể hiện một đường đi trực tiếp từ $v_i$ đến $v_j$ với khoảng cách $c_(i j)$ và thời lượng cần để di chuyển $delta_(i j)$.

Một hành trình khả thi $r$ được định nghĩa là một chu trình trong $G$ xuất phát và kết thúc tại $v_0$, sao cho tổng nhu cầu của khách hàng trong $r$ nhỏ hơn hoặc bằng $Q$. 

Bài toán VRPTW hướng đến việc xây dựng $m$ chuyến đi cho các xe để thăm các đỉnh đúng một lần trong khoảng thời gian cho phép, và cực tiểu hoá tổng khoảng cách đã di chuyển.

#figure(
  image("images/vrptw-1.svg", width: 100%),
) <glacier>


== Các nghiên cứu liên quan

#image("images/vrptw-2.png")

= Thuật toán

== Hàm mục tiêu

Xét một hành trình $r$, xuất phát từ $v_0$ $(sigma_0^r = 0)$, thăm $n_r$ khách hàng $(sigma_1^r, ..., sigma_(n_r)^r)$, sau đó quay trở lại điểm xuất phát $sigma_(n_r+1)^r=0$. Gọi $bold(t)^r = (t_0^r, ..., t_(n_r+1)^r)$ là thời điểm ta phục vụ điểm thứ $i$. Đường đi từ đỉnh $sigma_(i)^r$ đến $sigma_(i+1)^r$ sẽ gây ra độ trễ (time warp, nghĩa là thời gian vượt quá khả năng chờ của khách hàng) là $"tw"_(i,i+1) = max(t_i^r + tau_(sigma_i^r) + delta_(sigma_i^r sigma_(i+1)^r) - t_(i+1)^r, 0)$. Ta sẽ coi như tài xế chấp nhận việc trả một lượng chi phí là $"tw"_(i,i+1)$ để quay lại phục vụ khách hàng thứ $i+1$ tại thời điểm $l_(i+1)$

Các đại lượng sau đây đặc trưng cho tuyến đường $r$:
- Trọng tải $q(r) = sum_(i=1)^(n_r) q_(sigma_i^r)$
- Tổng khoảng cách $c(r) = sum_(i=0)^(n_r) c_(sigma_i^r sigma_(i+1)^r)$
- Tổng độ trễ $"tw"(r) = sum_(i=0)^(n_r) "tw"_(i,i+1)$

Ta cần tìm các hành trình sao cho tổng chi phí của các hành trình là tối thiểu, với chi phí của mỗi hành trình được tính bằng công thức:

$phi(r) = c_r + omega^Q max(0, q(r)-Q) + omega^("TW") "tw"(r)$

Trong đó $omega$ là các hệ số phạt tương ứng cho độ trễ và trọng tải thừa


#figure(
  image("images/vrptw-3.svg", width: 50%),
) <glacier>

== Tổng quan

#image("images/vrptw-5.svg")

== Quần thể

Thuật toán duy trì 2 quần thể, bao gồm các lời giải hợp lệ và không hợp lệ. Mỗi lần sản sinh ra một cá thể mới, chúng được chèn vào quần thể phù hợp. Ban đầu, $4mu$ lời giải được sinh ra dựa trên heuristics kiến trúc, cải tiến bằng local search và chèn lại vào bể tương ứng. Khi có một quần thể đạt $mu + lambda$ cá thể, các cá thể sẽ bị loại dần cho đến khi quần thể còn $mu$ lời giải. Việc này có thể thực hiện bằng việc xoá các lời giải trùng nhau. Sau khi lọc trùng, ta xoá các lời giải có độ phù hợp tồi nhất đi.

== Heuristics kiến trúc

Ban đầu, 100 lời giải ngẫu nhiên được sinh ra, sau đó được hiệu chỉnh sử dụng local search. Ngoài ra, để tăng tốc độ hội tụ, tác giả còn cài đặt 3 thuật toán tham lam để sinh lời giải ban đầu khác nhau bao gồm _nearest_, _farthest_ và _sweep_, mỗi thuật toán được sử dụng để xây dựng $5%$ lời giải ban đầu.

=== _nearest_, _farthest_
Ta sẽ xây dựng từng hành trình một. Ban đầu, một điểm bất kì gần/xa điểm tập kết nhất được chèn vào. Sau đó, ta lặp lại việc tìm một khách hàng chưa được phục vụ và vị trí để chèn nó vào hành trình hiện tại sao cho khoảng cách tăng lên là ít nhất và việc chèn khách hàng này vào không gây ra bất kì vi phạm nào về time window hoặc capacity, và tiến hành chèn vào. Nếu không thể chèn thêm bất kì khách hàng nào vào hành trình hiện tại, ta bắt đầu một chuyến mới và tiến hành tương tự.

Do việc chèn như vậy là tất định, nên để dựng được nhiều hơn một lời giải, ta có thể xây dựng thêm các lời giải gần khả thi, nghĩa là cho phép tổng độ trễ trong khoảng từ 0 đến 100, và tổng khối lượng thừa trong khoảng từ 0 đến 50.

```
S = {1, 2, 3, ..., n}
solutions <- []

for t = 1 to m:
  if S is empty:
    break
	
	i <- nearest/farthest customers from depot in S
	customers <- [i]
  remove i from S

	while S is not empty:
		j, p <- a customer in S that can be add to `customers` at p and causes least detour distance
		if j not exists:
			break
    insert best j into customers at p
    remove j from S

	append customers to solutions
```

=== _sweep_

- Sắp xếp các khách hàng theo góc giữa nó và điểm xuất phát.
- Thêm các khách hàng cho đến khi quá trọng tải.
- Với mỗi chuyến đi:
  - Sắp xếp các khách hàng có time window ngắn (< 50%) tăng dần theo $l_i$
  - Chèn lại các khách hàng có time window dài sao cho khoảng cách tăng là ít nhất.

Lưu ý thuật toán có thể cho ra các cấu hình vi phạm ràng buộc về thời gian. Để có thể xây dựng thêm lời giải, ta chạy lại thuật toán với trọng tải giảm ngẫu nhiên một lượng từ 0 đến $40%$.

== Lai tạo

=== Lựa chọn cha mẹ

#figure(
  image("images/vrptw-4.svg", width: 80%)
)

Để chọn một lời giải, thuật toán thực hiện "binary tournament" để lựa chọn, cụ thể như sau:

- Chọn ngẫu nhiên 2 lời giải trong tập các lời giải hiện tại với xác suất như nhau
- Trong 2 lời giải đó, chọn lời giải có độ phù hợp tốt hơn

Độ phù hợp của một lời giải được tính bằng công thức:

$f_P (S) = f_P ^(phi) (S) + (1 - n^("ELITE")/(|P|)) f_P^("DIV")(S)$

Trong đó:

- Hạng của một lời giải được tính bằng $"chỉ số của lời giải sau khi sắp xếp theo chất lượng"/"tổng số lời giải"$
- $f_P ^(phi) (S)$ là "hạng" của lời giải $S$, sắp xếp theo chất lượng lời giải.
- $f_P^("DIV")(S)$ là "hạng" của lời giải $S$, khi xét khả năng mở rộng (diversity contribution)
  - Có nhiều cách tính độ tốt khi xét đến khả năng mở rộng, nhưng theo thực nghiệm thì tốt nhất là sử dụng "broken pairs distance"
  - Broken pairs distance của một cặp $A$ và $B$ được tính bằng số cặp $(i, j)$ kề nhau trong $A$ nhưng *không* kề nhau trong $B$ (tính cả depot).
  #figure(
    image("images/vrptw-6.svg", width: 60%)
  )
  
  - Khả năng mở rộng của lời giải S, được tính bằng trung bình các broken pair distance từ S đến $n^("CLOSEST")$ lời giải có BPS đến S là nhỏ nhất.
  $Delta(S) = 1/(n^("CLOSEST")) sum_(S_2) delta(S, S_2)$
  
- Hệ số $(1 - n^("ELITE")/(|P|))$ được sử dụng để đảm bảo ta vẫn giữ lại được $n^("ELITE")$ lời giải chất lượng tốt nhất trong suốt quá trình tìm kiếm

=== Thao tác

*Toán tử tương giao chéo (Crossover operator)*. Xem lời giải như một hoán vị độ dài $n$. Chọn ngẫu nhiên một đoạn con $[l, r]$ của cha, và đưa đoạn này vào lời giải của con. Sau đó, xuất phát từ $r+1$, ta lần lượt đưa các nút chưa được sử dụng theo thứ tự xuất hiện trong lời giải mẹ vào lời giải con.

#figure(
  image("images/vrptw-7.svg", width: 70%)
)

Toán tử tương giao chéo này được thực hiện mà không xét đến các ràng buộc về khối lượng, thời gian hay về depot. Vì vậy, từ hoán vị đã tương giao, ta sử dụng thuật toán SPLIT để chia hoán vị đã tương giao về các xe khác nhau sao cho thoả mãn ràng buộc về trọng lượng.

(_SPLIT là một thuật toán giúp các lớp thuật toán di truyền có thể cho ra kết quả tốt hơn thuật toán tabu search truyền thống, khi nó giúp cho việc lai ghép 2 lời giải một cách dễ dàng hơn bằng việc cho phép phân chia một hoán vị ra các hành trình con. Từ đó, ta có thể sử dụng các phương pháp lai ghép truyền thống giữa các hoán vị cho bài toán này._)

Thuật toán SPLIT có thể hiểu đơn giản như một thuật toán quy hoạch động:

#figure(
  kind: "algorithm",
  supplement: [Algorithm],

  pseudocode-list(
    width: 100%,
    hooks: .5em,
    booktabs: true,
    numbered-title: [Class Split Algorithm: Fleet limited to $m$ vehicles #h(1fr)],
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
) <cool>

Tuy nhiên, trong thuật toán HGS-CVRP, thay vì quy hoạch động thuần tuý $O(n^2)$, thuật toán đã sử dụng kĩ thuật stack để giảm độ phức tạp xuống còn $O(n)$

// Algorithm 4 here

// #image("vrptw-17.png")

Chứng minh tính đúng đắn của thuật toán có thể tham khảo tại paper _Technical Note: Split algorithm in O(n) for the capacitated vehicle routing problem_.

Việc chia hoán vị như thuật toán HGS-CVRP ban đầu có thể gây cả vi phạm về thời gian, khi đó ta sử dụng local search để điều chỉnh với hi vọng toàn bộ vi phạm về thời gian sẽ được giải quyết.

*Selective Route Exchange (SREX).*

#image("images/vrptw-8.svg")

Hai lời giải con khác nhau được tạo ra phụ thuộc vào việc ... và ta sẽ chọn lời giải tốt nhất khi xét đến hàm mục tiêu. Vì SREX, nó không dùng đến thuật toán SPLIT kể trên, vì vậy nó phù hợp hơn khi sử dụng để giải bài toán có ràng buộc về thời gian.

Two different offspring solutions are created dependent on from which parents' routes the
duplicate nodes are removed and we continue with the best solution (in terms of penalized cost).
Since SREX preserves depot visits, it does not use the SPLIT algorithm and is thus more suitable
for time windows.

*Sửa đổi quần thể.* Cuối cùng, ta sinh ra con cháu sử dụng cả hai loại thao tác trên, và tiếp tục đến bước local search với lời giải tốt nhất khi xét 2 thao tác.

== Local search

_Yet, these procedures tend inevitably to make for the largest part (90-95%) of the overall
computational effort, such that high computational efficiency is
required. Three basic aspects are decisive for performance: (1) a
suitable choice of neighbourhood, restricted to relevant moves
while being large enough to allow some structural solution
changes; (2) memory structures to evade redundant move computations; and (3) highly efficient neighbour cost and feasibility
evaluations. We introduce new methodologies to address these
aspects relatively to the specificities of time-constrained VRPs._

Thủ tục được áp dụng sau khi sinh lời giải ngẫu nhiên, và để hiệu chỉnh lời giải sau khi lai ghép. Các operator được sử dụng:

*Swap.*

*Relocate.*

*2-opt\**. Chọn 2 tuyến đường $r$ và $r'$, mỗi tuyến đường ta chọn một vị trí bất kì. Sau đó đổi chỗ $(sigma_i^r, ..., sigma_(n_r)^i)$ và $(sigma_i'^r', ..., sigma_(n_r')^i')$

*2-opt*. Chọn một tuyến đường $r$ và một đoạn con $[i,j]$ thuộc $r$, sau đó đảo ngược đoạn $(sigma_i^r, ..., sigma_j^r)$

*Swap\**.

_if the routes involved in a move currently have 0 time-warp, then we first check
only if the move will reduce the total distance. If this is not the case, the move can never be
improving and we can discard the move, avoiding the expensive TW-data computation._

_Để tăng tốc độ cho quá trình local search, các cấu hình láng giềng cũng được cắt tỉa sử dụng các thước đo tương quan. Tập các láng giềng có tương quan trong các bài toán VRP cổ điện liên quan đến một thước đo gần không gian. Tuy nhiên, bài toán VRP có ràng buộc thời gian lại bao gồm một chiều khác, liên quan đến độ gần về thời gian (time proximity), cũng như các vấn đề bổ sung về tính bất đối xứng. Do đó, các quan hệ tương quan trở nên khó định nghĩa hơn._

Tóm lại, việc ta lựa chọn một vị trí $i$ để thực hiện thao tác, thì mình cần phải lựa chọn làm sao để sau khi thực hiện thao tác tại vị trí $i$, thì chi phí gây ra cho những thằng láng giềng quanh nó (index $i-1$ hoặc $i+1$) là nhỏ nhất. Và chi phí gây ra đó được tính bằng sự đóng góp về mặt thời gian và khoảng cách, được giới thiệu trong công thức sau đây:

Với mỗi khách hàng $i$, ta định nghĩa một tập $Gamma(i)$ gồm $Gamma$ khách hàng gần $i$ nhất theo độ đo tương quan dưới đây:

$gamma(i,j) = c_(i j) + gamma^("WT") max(e_j - tau_i - delta_(i j) - l_i, 0) + gamma^("TW") max(e_i + tau_i + delta_(i j) - l_j, 0)$

Với $gamma^("WT")$ là hệ số cho việc chờ đợi khi xuất phát từ $i$ tại thời điểm $l_i$ và đi trực tiếp đến $j$, và $gamma^("TW")$ là hệ số phạt cho time-warp khi đi từ $i$ đến $j$.

Thước đo tương quan này tương ứng với tổng có trọng số của ba thành phần:
- Khoảng cách
- Thời gian chờ tối thiểu
- Mức phạt tối thiểu

// #image("vrptw-15.png")

Lúc này, khi thực hiện các thao tác:
- 2-opt: chỉ xét các cặp $(i,j)$ có $sigma_(j+1) in Gamma(sigma_i)$ hoặc $sigma_j in Gamma(sigma_(i-1))$
- Swap, replace: ?

Số trạng thái cần duyệt lúc này là $O(Gamma n)$ thay vì $O(n^2)$

Vì ta cho phép việc tìm kiếm ra các lời giải không hợp lệ, có thể sau khi tìm kiếm cục bộ, lời giải tìm được vẫn không hợp lệ. Khi điều này xảy ra, ta sẽ tiến hành sửa chữa (Repair operation) với xác suất $50%$. Nghĩa là ta sẽ thực hiện việc local search với các hệ số phạt tăng lên $10$ lần với hi vọng sẽ cho ra một lời giải hơp lệ. Lưu ý, nếu thực hiện lựa chọn sửa chữa, chỉ khi sửa được lời giải ta mới cho lại nó vào quần thể.
  
== Lựa chọn tham số

Các hằng số cố định: $n^("ELITE")=4$, $n^("CLOSEST")=5$, $lambda = 40$.

// #image("image (3).png")

Ban đầu, $omega^Q$ và $omega^("TW")$ được gán bằng 1. Sau mỗi 100 lần lặp, các tham số được tăng lên 20% nếu như có ít hơn $15%$ lời giải hợp lệ, và giảm 15% nếu có nhiều hơn 25% lời giải hợp lệ. Bên cạnh đó, nếu không tìm được lời giải nào hợp lệ, các tham số được tăng lên 100%, để tránh việc không tìm được lời giải trong một thời gian quá lâu. Sử dụng cơ chế này tốt hơn dùng penalty lớn từ đầu, do dùng penalty to khiến thuật toán hội tụ quá nhanh về nghiệm cục bộ.

Cách điều chỉnh tham số:

// #image("image (2).png", width:80%)

Sau 10000 lần lặp mà không có cải tiến nào, ta reset lại quần thể và vẫn giữ nguyên tham số cũ.

== Tổng kết

// #image("vrptw-16.png")

= Reference

- Thi Diem Chau LE, Clustering algorithm for a vehicle routing problem with time windows
- Yuichi Nagata, A penalty-based edge assembly memetic algorithm for the vehicle routing problem with time windows