!> Reynolds 算子投影
!> ngroup 是对称群的阶，即置换操作的总数
!> mat_rey 存储的是 Reynolds 算子的置换映射矩阵
!> 这个矩阵定义了同原子置换（Permutation）是如何打乱并重组变量索引的
module mod_reynolds
    implicit none
    integer :: nr, ngroup
    integer, allocatable :: mat_rey(:, :)
end module mod_reynolds

module mod_sympoly
    implicit none
    integer :: npoly
    !> maxv 是允许生成的单项式/对称多项式的最大数量上限
    !> 如果体系的阶数过高或者原子数过多, 导致生成的对称多项式数量超过此值, 就会寄
    !> 如果寄了记得多加点 0
    integer, parameter :: maxv = 100000
    real(kind=8) :: vrec(maxv)
    real(kind=8), allocatable :: rtest(:)
    integer, allocatable :: mons(:, :, :), polys(:, :)
    integer, allocatable :: vrecx(:, :)
    integer :: monid(maxv)
end module mod_sympoly

!> 生成所有可能的指数项
module mod_genpoly
    implicit none
    !> maxb 的风险同 maxv
    integer, parameter :: maxb = 100000
    integer, allocatable :: b(:, :), norder(:), btotal(:, :)
    integer :: ntotb
end module mod_genpoly

module mod_fi
    implicit none
    !> nfi: 记录当前已经确认线性独立的 FI 的总数
    integer :: nfi
    !> fmons & fmonid 存储这些真正的 FI 的指数矩阵和 ID
    integer, allocatable :: fmons(:, :, :), fmonid(:)
    !> nexit 是提前退出的断点, 即各阶需要的 FI 的数量
    integer, allocatable :: nexit(:)
end module mod_fi

!> 最多只支持 20 个原子，因为 20 * (20 - 1) / 2 = 190
module mod_molecule
    implicit none
    integer :: nrs
    integer :: idrf(190), idrs(190)
end module mod_molecule
