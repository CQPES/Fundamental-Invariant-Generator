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
    integer, parameter :: maxb = 100000
    integer, allocatable :: b(:, :), norder(:), btotal(:, :)
    integer :: ntotb
end module mod_genpoly

module mod_fi
    implicit none
    integer :: nfi
    integer, allocatable :: fmons(:, :, :), fmonid(:)
    integer, allocatable :: nexit(:)
end module mod_fi

!> 最多只支持 20 个原子，因为 20 * (20 - 1) / 2 = 190
module mod_molecule
    implicit none
    integer :: nrs
    integer :: idrf(190), idrs(190)
end module mod_molecule
