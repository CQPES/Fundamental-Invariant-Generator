!> 哈基米说这个模块本质上就是基于 DFS 的组合数学生成器 + 置换群轨道去重器
subroutine sym_poly(degree, np)
    ! calculate the symmetric polynomials
    ! in degree N, save the corresponding
    ! monomials to mons in module
    ! output: mons(in module), np
    use mod_sympoly, only: npoly
    implicit none
    integer, intent(in) :: degree
    integer, intent(out) :: np
    integer :: a(degree)
    npoly = 0
    call intsplit(degree, 1, a)
    np = npoly
end subroutine sym_poly

!> 阶数分配, 把目标多项式的总阶数拆分成不同变量的指数之和
!> 比如传入 degree = 3, 它就会吐出来 [3], [2, 1], [1, 1, 1] 这样的整数拆分序列
!> 放在数组 a 中, 代码传给下一层叫 coef
recursive subroutine intsplit(n, index, a)
    use mod_reynolds, only: nr
    implicit none
    integer, intent(in) :: n, index
    integer, intent(inout) :: a(*)
    integer :: i
    integer :: x(nr) !
    if (n .le. 0) then
        call combinations(1, nr - index + 1 + 1, 1, index - 1, nr, a(1:index - 1), x)
        !  write(*,'(100(1x,i3))') a(1:index-1)
        return
    end if
    do i = n, 1, -1
        a(index) = i
        call intsplit(n - i, index + 1, a)
    end do
end subroutine intsplit

recursive subroutine combinations(ia, ib, id, m, n, coef, x)
    use mod_reynolds, only: nr
    use mod_sympoly, only: rtest, npoly
    implicit none
    integer, intent(in) :: ia, ib, id, m, n, coef(m)
    integer, intent(inout) :: x(nr)
    integer :: i, flag
    real(kind=8) :: v
    if (id .gt. m) then
        call reduce(id, x, coef, flag)
        !call poly_value(id,x,coef,rtest,v)
        !call compare_value(v,flag)
        if (flag .eq. 0) then
            call save_monomials(id, x, coef)
        end if
        !if(flag.eq.1) then
        !  npoly=npoly+1
        !  call save_monomials(id,x,coef)
        !endif
        return
    end if
    do i = ia, ib
        x(id) = i
        call combinations(i + 1, ib + 1, id + 1, m, n, coef, x)
    end do
end subroutine combinations

!> 这里是去除的核心
!> 拿到一个新生成的单项式 (xid & coef 定义), 不能直接加入基底, 因为它可能和已经生成的单项式
!> 在对称群投影下是等价的
!> 1. 它先维护一个记录库 vrecx, 大小为 nr * maxv, 每一列代表一个已经确认的、唯一的不变多项式基底
!> 2. 对于新生成的单项式, 它开启一个 ngroup（群阶）大小的循环
!> 3. 利用 Reynolds 矩阵 mat_rey, 它将当前单项式映射到置换操作 j 下的新形态 vtmp
!> 4. 把置换后的 vtmp 去和库里已有的所有基底 vrecx(:, i) 精确对比
!> 5. 如果匹配上了, 那说明属于同一个对称群轨道, 也就是同一个基础不变多项式, 直接丢弃 flag = 1
subroutine reduce(id, xid, coef, flag)
    use mod_reynolds, only: nr, ngroup, mat_rey
    use mod_sympoly, only: npoly, vrecx, maxv
    implicit none
    integer, intent(in) :: id, xid(id - 1), coef(id - 1)
    integer, intent(out) :: flag
    integer :: i, j, k
    integer :: vtmp(nr), tmp
    flag = 1
    if (npoly .eq. 0) then
        flag = 0
        npoly = 1
        vrecx(:, npoly) = 0
        do j = 1, id - 1
            vrecx(mat_rey(xid(j), 1), npoly) = coef(j)
        end do
    elseif (npoly .ge. 1) then
        flag = 0
        !> 见注释 2
        do j = 1, ngroup
            vtmp = 0
            do k = 1, id - 1
                !> 见注释 3
                !> 它通过矩阵查表, 执行了变量索引的置换, 并把指定 coef 赋值给置换后的新位置
                vtmp(mat_rey(xid(k), j)) = coef(k)
            end do
            do i = 1, npoly
                !> 见注释 4
                tmp = sum(abs(vtmp - vrecx(:, i)))
                !> 见注释 5
                if (tmp .eq. 0) then
                    flag = 1
                    exit
                end if
            end do
            !> 见注释 5, 这里 flag = 1 被丢弃了!
            if (flag .eq. 1) then
                exit
            end if
        end do
        !> 见注释 5, flag = 0, 说明是新的轨道, 可以保存起来!
        if (flag .eq. 0) then
            npoly = npoly + 1
            vrecx(:, npoly) = 0
            !> 这里从 coef 里取过来
            do j = 1, id - 1
                vrecx(mat_rey(xid(j), 1), npoly) = coef(j)
            end do
            !> 这里判断多项式数量有没有超了
            if (npoly .gt. maxv) then
                write (*, *) " !!! Error: number of polynomials exceeds..."
            end if
        end if
    end if
end subroutine reduce

subroutine poly_value(id, xid, coef, r0, v)
    use mod_reynolds, only: nr, ngroup, mat_rey
    implicit none
    integer, intent(in) :: id, xid(id - 1), coef(id - 1)
    real(kind=8), intent(in) :: r0(nr)
    real(kind=8), intent(out) :: v
    real(kind=8) :: tmp
    integer :: j, k
    v = 0.d0
    do k = 1, ngroup
        tmp = 1.d0
        do j = 1, id - 1
            tmp = tmp*r0(mat_rey(xid(j), k))**(real(coef(j)))
        end do
        v = v + tmp
    end do
end subroutine poly_value

subroutine compare_value(v, flag)
    use mod_sympoly, only: npoly, vrec, maxv
    implicit none
    real(kind=8), intent(in) :: v
    integer, intent(out) :: flag
    real(kind=8) :: tmp
    integer :: i
    !------------------------
    ! compare the value of the new polynomial
    ! with the rest existing polynomials
    flag = 1
    if (npoly .eq. 0) then
        flag = 0
        npoly = 1
        vrec(1) = v
    elseif (npoly .ge. 1) then
        flag = 0
        do i = 1, npoly
            tmp = abs(vrec(i) - v)
            if (tmp .lt. 1.d-9) then
                flag = 1
            end if
        end do
        if (flag .eq. 0) then
            npoly = npoly + 1
            vrec(npoly) = v
            if (npoly .gt. maxv) then
                write (*, *) " !!! Error: number of polynomials exceeds..."
            end if
        end if
    end if
end subroutine compare_value

subroutine save_monomials(id, x, coef)
    use mod_sympoly, only: mons, npoly, monid
    implicit none
    integer, intent(in) :: id, x(id - 1), coef(id - 1)
    integer :: j
    monid(npoly) = id
    do j = 1, id - 1
        mons(1, j, npoly) = x(j)
        mons(2, j, npoly) = coef(j)
    end do
end subroutine save_monomials
