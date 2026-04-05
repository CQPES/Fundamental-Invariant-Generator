!> 哈基米帮忙重构了一下，主要解决手动处理字符串宽度的问题
subroutine write_poly(id, x, coef, np)
    use mod_reynolds, only: nr, ngroup, mat_rey
    use mod_sympoly, only: polys
    use mod_molecule, only: idrf
    implicit none
    integer, intent(in) :: id, coef(id - 1), x(id - 1), np
    character(len=100) :: charc, charx, charp, charf
    integer :: i, j, k, npoly, i0, idr, idc, maxp
    integer :: nchar

    write (707, '(1(i8))', advance='no') id
    do j = 1, id - 1
        write (707, '(2(i8))', advance='no') x(j), coef(j)
    end do
    write (707, *) ""

    polys = 0
    npoly = 0
    do k = 1, ngroup
        do j = 1, id - 1
            i = mat_rey(x(j), k)
            polys(i, npoly + 1) = coef(j)
        end do
        if (npoly .eq. 0) then
            npoly = npoly + 1
            polys(0, npoly) = 1
        else
            i0 = 0
            do j = 1, npoly
                i = sum(abs(polys(1:nr, j) - polys(1:nr, npoly + 1)))
                if (i .eq. 0) then
                    polys(0, j) = polys(0, j) + 1
                    polys(0:nr, npoly + 1) = 0
                    exit
                else
                    i0 = i0 + 1
                end if
            end do
            if (i0 .eq. npoly) then
                npoly = npoly + 1
                polys(0, npoly) = 1
            end if
        end if
    end do

    write (charc, *) np - 1
    write (charf, *) np
    
    write (703, '("p",a,"=")', advance='no') trim(adjustl(charf))
    write (705, '("p(",a,")=")', advance='no') trim(adjustl(charf))
    write (711, '("p[",a,"]=")', advance='no') trim(adjustl(charc))
    write (717, '("p_{",a,"}=")', advance='no') trim(adjustl(charf))
    
    ! 精确初始化 Fortran 输出的字符计数器
    nchar = len_trim(adjustl(charf)) + 4

    do k = 1, npoly
        maxp = 0
        do j = 1, nr
            if (polys(j, k) .gt. 0) then
                maxp = j
            end if
        end do

        do j = 1, nr
            idr = idrf(j); idc = polys(j, k)
            if (polys(j, k) .gt. 0) then
                write (charx, *) idr
                write (charc, *) idr - 1
                write (charp, *) idc
                
                if (idc .eq. 1) then
                    write (703, '("r",a)', advance='no') &
                        trim(adjustl(charx))
                    write (717, '("r_{",a,"}")', advance='no') &
                        trim(adjustl(charx))
                    
                    if (j .lt. maxp) then
                        write (705, '("r(",a,")*")', advance='no') &
                            trim(adjustl(charx))
                        write (711, '("r[",a,"]*")', advance='no') &
                            trim(adjustl(charc))

                        nchar = nchar + len_trim(adjustl(charx)) + 4
                    else
                        write (705, '("r(",a,")")', advance='no') &
                            trim(adjustl(charx))
                        write (711, '("r[",a,"]")', advance='no') &
                            trim(adjustl(charc))

                        nchar = nchar + len_trim(adjustl(charx)) + 3
                    end if
                else
                    write (703, '("r",a,"^",a)', advance='no') &
                        trim(adjustl(charx)), trim(adjustl(charp))
                    write (717, '("r_{",a,"}^{",a,"}")', advance='no') &
                        trim(adjustl(charx)), trim(adjustl(charp))
                    
                    if (j .lt. maxp) then
                        write (705, '("r(",a,")**",a,"*")', advance='no') &
                            trim(adjustl(charx)), trim(adjustl(charp))
                        write (711, '("r[",a,"]^",a,"*")', advance='no') &
                            trim(adjustl(charc)), trim(adjustl(charp))

                        nchar = nchar + len_trim(adjustl(charx)) + &
                            len_trim(adjustl(charp)) + 6
                    else
                        write (705, '("r(",a,")**",a)', advance='no') &
                            trim(adjustl(charx)), trim(adjustl(charp))
                        write (711, '("r[",a,"]^",a)', advance='no') &
                            trim(adjustl(charc)), trim(adjustl(charp))

                        nchar = nchar + len_trim(adjustl(charx)) + &
                            len_trim(adjustl(charp)) + 5
                    end if
                end if
            end if
        end do
        
        if (k .lt. npoly) then
            write (703, '("+")', advance='no')
            write (717, '("+")', advance='no')

            if (nchar .gt. 80) then
                nchar = 0
                write (705, *) "&"
            end if
            
            write (705, '("+")', advance='no')
            write (711, '("+")', advance='no')
        end if
    end do
    
    write (703, *) ""
    write (717, *) ""
    write (705, *) ""
    write (711, *) ""
end subroutine write_poly

!> 哈基米帮忙重构了一下，主要解决手动处理字符串宽度的问题
subroutine write_rsingle
    use mod_molecule, only: nrs, idrs
    use mod_fi, only: nfi
    implicit none
    character(len=100) :: charc, charr, charcx, charrx
    integer :: i, id
    
    do i = 1, nrs
        id = nfi + i

        write (charc, *) id
        write (charr, *) idrs(i)
        write (charcx, *) id - 1
        write (charrx, *) idrs(i) - 1

        ! Fortran
        write (705, '("p(",a,")=r(",a,")")') trim(adjustl(charc)), trim(adjustl(charr))
        ! LaTeX
        write (717, '("p_{",a,"}=r_{",a,"}")') trim(adjustl(charc)), trim(adjustl(charr))
        ! C/Python
        write (711, '("p[",a,"]=r[",a,"]")') trim(adjustl(charcx)), trim(adjustl(charrx))
    end do
end subroutine write_rsingle
