!> 哈基米说这个是 FI 生成流水线
!> 按阶数逐层生成对称多项式 -> 组合低阶 FI -> 过滤独立项 -> 输出
subroutine fundamental
    use mod_reynolds, only: nr, ngroup
    use mod_sympoly, only: rtest, mons, maxv, monid, polys, vrecx
    use mod_genpoly, only: norder, b, btotal, maxb
    use mod_fi, only: nfi, fmons, fmonid, nexit
    implicit none
    integer :: degree, np, nb
    integer :: i, j, nx0, ny0
    real(kind=8), allocatable :: frtest(:, :)

    ! degree of the fundamental invariants to be calculated
    !> 这里是读一行注释行再读一个 degree 和一个 number of exit point
    read (*, *); read (*, *) degree, i
    write (601, '("degree and number of exit point:")'); write (601, '((i2,1x,i2))') degree, i
    allocate (nexit(0:i))
    nexit(0) = i
    read (*, *); read (*, *) nexit(1:i)
    write (601, '("exit index of FI:")')
    do i = 1, nexit(0)
        write (601, '(i4)', advance='no') nexit(i)
    end do
    allocate (norder(degree))
    allocate (rtest(nr), mons(2, nr, maxv), polys(0:nr, ngroup))
    allocate (fmons(2, nr, maxv), fmonid(maxv), frtest(nr, maxv))
    allocate (b(degree, maxb), btotal(0:degree, maxb))
    allocate (vrecx(nr, maxv))
    !> 用于后面线性独立性测试的随机核间距
    call random_number(rtest)
    call random_number(frtest)
    frtest = frtest*5.d0
    nfi = 0
    norder = 0
    open (701, file='dat.log', status='replace')
    open (702, file='dat.err', status='replace')
    open (703, file='dat.polys', status='replace')
    open (705, file='dat.fpolys', status='replace')
    open (707, file='dat.nfi', status='replace')
    open (711, file='dat.cpolys', status='replace')
    open (717, file='dat.latex', status='replace')
    !> 原版代码这里没注释掉, 不注释不能 work
    !-----------------
    !   do i = 1, 10
    !      call sym_poly(i, np)
    !      write (*, *) "*", np
    !      do j = 1, np
    !         call write_poly(monid(j), mons(1, 1:monid(j) - 1, j), mons(2, 1:monid(j) - 1, j), j)
    !      end do
    !   end do
    !   stop
    !-----------------
    !> 这里是逐阶向上构建 FI
    do i = 1, degree
        !> 生成第 i 阶有所有置换对称多项式, 总数为 np
        call sym_poly(i, np)
        if (i .eq. 1) then
            !> 1 阶多项式一定是线性独立的, 这个不用担心
            fmons(:, :, 1:np) = mons(:, :, 1:np)
            fmonid(1:np) = monid(1:np)
            norder(1) = np
            nfi = np
            do j = 1, nfi
                !> 直接写文件里
                call write_poly(fmonid(j), fmons(1, 1:fmonid(j) - 1, j), fmons(2, 1:fmonid(j) - 1, j), j)
                write (702, '(i6,"*  ",i5,",",i5," in degree ",(i2),",")') j, j, np, i
            end do
        else if (i .gt. 1) then
            !> 先生成已知的 FI 组合项 (secondary invariants)
            call gen_poly(i, nb)
            !> np: 新的候选对称多项式的数量
            !> nb: 已知低阶 FI 组合出的多项式数量
            !> nx0: 行数 (测试样本的容量), 必须大于列数保证超定
            nx0 = nb + np + 100 ! nx >= ny+1 in the dgels, here add 100
            !> ny0: 列数 (基底容量上限)
            ny0 = nfi + nb + np
            !> 通过最小二乘法筛掉线性相关的, 留下真正的新的 FI
            call cal_error(nx0, ny0, np, nb, frtest, i)
        end if
        !> 写日志
        write (701, '(i3," fundamental invariants, ",i4," symmetric polynomials in degree: ",i3)') norder(i), np, i
        !> 如果在这一阶一个新的 FI 都没找到, 那说明空间已经闭合或饱和, 不用再生成了
        if (norder(i) .eq. 0) exit; 
    end do
    !> 清理
    call write_rsingle
    close (701); close (702); close (703); close (705); close (707); close (711); close (717)
    !> 人还怪好的, 还记得释放内存
    deallocate (norder, rtest, mons, polys)
    deallocate (fmons, fmonid, frtest)
    deallocate (b, btotal)
    deallocate (vrecx)
end subroutine fundamental
