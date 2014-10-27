      program zndrv3
c
c     Simple program to illustrate the idea of reverse communication
c     in inverse mode for a generalized complex nonsymmetric eigenvalue 
c     problem.
c
c     We implement example three of ex-complex.doc in DOCUMENTS directory
c
c\Example-3
c     ... Suppose we want to solve A*x = lambda*B*x in regular mode,
c         where A and B are derived from the finite element discretization
c         of the 1-dimensional convection-diffusion operator
c                   (d^2u/dx^2) + rho*(du/dx)
c         on the interval [0,1] with zero boundary condition using 
c         piecewise linear elements. 
c
c     ... OP = inv[M]*A  and  B = M.
c
c     ... Use mode 2 of ZNAUPD.
c
c\BeginLib
c
c\Routines called:
c     znaupd  ARPACK reverse communication interface routine.
c     zneupd  ARPACK routine that returns Ritz values and (optionally)
c             Ritz vectors.
c     zgttrf  LAPACK tridiagonal factorization routine.
c     zgttrs  LAPACK tridiagonal solve routine.
c     dlapy2  LAPACK routine to compute sqrt(x**2+y**2) carefully.
c     zaxpy   Level 1 BLAS that computes y <- alpha*x+y.
c     dznrm2  Level 1 BLAS that computes the norm of a vector.
c     av      Matrix vector multiplication routine that computes A*x.
c     mv      Matrix vector multiplication routine that computes M*x.
c
c\Author
c     Richard Lehoucq
c     Danny Sorensen
c     Chao Yang
c     Dept. of Computational &
c     Applied Mathematics
c     Rice University
c     Houston, Texas
c
c\SCCS Information: @(#)
c FILE: ndrv3.F   SID: 2.2   DATE OF SID: 4/22/96   RELEASE: 2
c
c\Remarks
c     1. None
c
c\EndLib
c--------------------------------------------------------------------------
c
c     %-----------------------------%
c     | Define leading dimensions   |
c     | for all arrays.             |
c     | MAXN:   Maximum dimension   |
c     |         of the A allowed.   |
c     | MAXNEV: Maximum NEV allowed |
c     | MAXNCV: Maximum NCV allowed |
c     %-----------------------------%
c
      integer           lx1, ly1, lz1, lelv, ltot1
      parameter         (lx1=14, ly1=lx1, lz1=1, lelv=15, 
     &                   ltot1=lx1*ly1*lz1*lelv)
      integer           maxn, maxnev, maxncv, ldv
      parameter         (maxn=2*ltot1, maxnev=10, maxncv=25, 
     &                   ldv=maxn )
c
c     %--------------%
c     | Local Arrays |
c     %--------------%
c
      integer           iparam(11), ipntr(14), ipiv(maxn)
      logical           select(maxncv)
      Complex*16
     &                  ax(maxn), mx(maxn), d(maxncv), resid(maxn),
     &                  v(ldv,maxncv), workd(3*maxn), 
     &                  workev(2*maxncv),
     &                  workl(3*maxncv*maxncv+5*maxncv),
     &                  dd(maxn), dl(maxn), du(maxn), du2(maxn)
      Double precision            
     &                  rwork(maxn), rd(maxncv,3)
c
c     %---------------%
c     | Local Scalars |
c     %---------------%
c
      character         bmat*1, which*2
      integer           ido, n, nev, ncv, lworkl, info, ierr, j,
     &                  nconv, maxitr, ishfts, mode
      Complex*16           
     &                  sigma, h
      Double precision
     &                  tol
      logical           rvec
c
c     %------------%
c     | Parameters |
c     %------------%
c
      Complex*16  
     &                  zero, one
      parameter         (zero = (0.0D+0, 0.0D+0),
     &                   one = (1.0D+0, 0.0D+0))
c
c     %-----------------------------%
c     | BLAS & LAPACK routines used |
c     %-----------------------------%
c
      Double precision 
     &                  dznrm2, dlapy2
      external          zaxpy, zcopy, dznrm2, zgttrf, zgttrs, dlapy2
c
c     %-----------------------%
c     | Executable Statements |
c     %-----------------------%
c
c     %----------------------------------------------------%
c     | The number N is the dimension of the matrix.  A    |
c     | generalized eigenvalue problem is solved (BMAT =   |
c     | 'G').  NEV is the number of eigenvalues to be      |
c     | approximated.  The user can modify NEV, NCV, WHICH |
c     | to solve problems of different sizes, and to get   |
c     | different parts of the spectrum.  However, The     |
c     | following conditions must be satisfied:            |
c     |                    N <= MAXN,                      |
c     |                  NEV <= MAXNEV,                    |
c     |              NEV + 2 <= NCV <= MAXNCV              |
c     %----------------------------------------------------%
c
      n     = 2*ltot1
      nev   = 4 
      ncv   = 20 
      if ( n .gt. maxn ) then
         print *, ' ERROR with _NDRV3: N is greater than MAXN '
         go to 9000
      else if ( nev .gt. maxnev ) then
         print *, ' ERROR with _NDRV3: NEV is greater than MAXNEV '
         go to 9000
      else if ( ncv .gt. maxncv ) then
         print *, ' ERROR with _NDRV3: NCV is greater than MAXNCV '
         go to 9000
      end if
      bmat  = 'G'
      which = 'SM'
      sigma = zero
c
c     %-----------------------------------------------------%
c     | The matrix M is chosen to be the symmetric tri-     |
c     | diagonal matrix with 4 on the diagonal and 1 on the |
c     | off diagonals. It is factored by LAPACK subroutine  |
c     | zgttrf.                                             |
c     %-----------------------------------------------------%
c
c
c     %-----------------------------------------------------%
c     | The work array WORKL is used in ZNAUPD as           |
c     | workspace.  Its dimension LWORKL is set as          |
c     | illustrated below.  The parameter TOL determines    |
c     | the stopping criterion. If TOL<=0, machine          |
c     | precision is used.  The variable IDO is used for    |
c     | reverse communication, and is initially set to 0.   |
c     | Setting INFO=0 indicates that a random vector is    |
c     | generated in ZNAUPD to start the Arnoldi iteration. |
c     %-----------------------------------------------------%
c
      lworkl = 3*ncv**2+5*ncv 
      tol    = 0.0 
      ido    = 0
      info   = 0
c
c     %---------------------------------------------------%
c     | This program uses exact shifts with respect to    |
c     | the current Hessenberg matrix (IPARAM(1) = 1).    |
c     | IPARAM(3) specifies the maximum number of Arnoldi |
c     | iterations allowed.  Mode 2 of ZNAUPD is used     |
c     | (IPARAM(7) = 2).  All these options can be        |
c     | changed by the user. For details, see the         |
c     | documentation in ZNAUPD.                          |
c     %---------------------------------------------------%
c
      ishfts = 1
      maxitr = 10
      mode   = 2
c
      iparam(1) = ishfts
      iparam(3) = maxitr  
      iparam(7) = mode 
c
c     %-------------------------------------------%
c     | M A I N   L O O P (Reverse communication) |
c     %-------------------------------------------%
c
 10   continue
c
c        %---------------------------------------------%
c        | Repeatedly call the routine ZNAUPD and take | 
c        | actions indicated by parameter IDO until    |
c        | either convergence is indicated or maxitr   |
c        | has been exceeded.                          |
c        %---------------------------------------------%
c
         call znaupd ( ido, bmat, n, which, nev, tol, resid, ncv, 
     &        v, ldv, iparam, ipntr, workd, workl, lworkl, 
     &        rwork, info )
c
         if (ido .eq. -1 .or. ido .eq. 1) then
c
c           %----------------------------------------%
c           | Perform  y <--- OP*x = inv[M]*A*x      |
c           | The user should supply his/her own     |
c           | matrix vector routine and a linear     |
c           | system solver.  The matrix-vector      |
c           | subroutine should take workd(ipntr(1)) |
c           | as input, and the final result should  |
c           | be returned to workd(ipntr(2)).        |
c           %----------------------------------------%
c
            call op (n, workd(ipntr(1)), workd(ipntr(2)))
            if ( ierr .ne. 0 ) then
               print*, ' ' 
               print*, ' ERROR with _gttrs. ' 
               print*, ' '
               go to 9000
            end if
c
c           %-----------------------------------------%
c           | L O O P   B A C K to call ZNAUPD again. |
c           %-----------------------------------------%
c
            go to 10
c
         else if ( ido .eq. 2) then
c
c           %-------------------------------------%
c           |        Perform  y <--- M*x          |
c           | The matrix vector multiplication    |
c           | routine should take workd(ipntr(1)) |
c           | as input and return the result to   |
c           | workd(ipntr(2)).                    |
c           %-------------------------------------%
c
            call mv (n, workd(ipntr(1)), workd(ipntr(2)))
c
c           %-----------------------------------------%
c           | L O O P   B A C K to call ZNAUPD again. |
c           %-----------------------------------------%
c
            go to 10
c
         end if
c
c     %-----------------------------------------%
c     | Either we have convergence, or there is |
c     | an error.                               |
c     %-----------------------------------------% 
c
      if ( info .lt. 0 ) then
c
c        %--------------------------%
c        | Error message. Check the |
c        | documentation in ZNAUPD. |
c        %--------------------------%
c
         print *, ' '
         print *, ' Error with _naupd, info = ',info
         print *, ' Check the documentation of _naupd.'
         print *, ' ' 
c
      else 
c
c        %-------------------------------------------%
c        | No fatal errors occurred.                 |
c        | Post-Process using ZNEUPD.                |
c        |                                           |
c        | Computed eigenvalues may be extracted.    |  
c        |                                           |
c        | Eigenvectors may also be computed now if  |
c        | desired.  (indicated by rvec = .true.)    | 
c        %-------------------------------------------%
c
         rvec = .true.
c
         call zneupd ( rvec, 'A', select, d, v, ldv, sigma, 
     &        workev, bmat, n, which, nev, tol, resid, ncv, v, 
     &        ldv, iparam, ipntr, workd, workl, lworkl, rwork,
     &        ierr )
c
c        %----------------------------------------------%
c        | Eigenvalues are returned in the one          |
c        | dimensional array D.  The corresponding      |
c        | eigenvectors are returned in the first NCONV |
c        | (=IPARAM(5)) columns of the two dimensional  |
c        | array V if requested.  Otherwise, an         |
c        | orthogonal basis for the invariant subspace  |
c        | corresponding to the eigenvalues in D is     |
c        | returned in V.                               |
c        %----------------------------------------------%
c
         if ( ierr .ne. 0 ) then
c
c           %------------------------------------%
c           | Error condition:                   |
c           | Check the documentation of ZNEUPD. |
c           %------------------------------------%
c 
            print *, ' ' 
            print *, ' Error with _neupd, info = ', ierr
            print *, ' Check the documentation of _neupd'
            print *, ' '
c
         else
c
            nconv = iparam(5)
            do 80 j=1, nconv 
c
c              %---------------------------%
c              | Compute the residual norm |
c              |                           |
c              |  ||  A*x - lambda*M*x ||  |
c              |                           |
c              | for the NCONV accurately  |
c              | computed eigenvalues and  |
c              | eigenvectors.  (iparam(5) |
c              | indicates how many are    |
c              | accurate to the requested |
c              | tolerance)                |
c              %---------------------------%
c
               call av(n, v(1,j), ax)
               call mv(n, v(1,j), mx)
               call zaxpy(n, -d(j), mx, 1, ax, 1)
               rd(j,1) = dble(d(j))
               rd(j,2) = dimag(d(j))
               rd(j,3) = dznrm2(n, ax, 1)
               rd(j,3) = rd(j,3) / dlapy2(rd(j,1),rd(j,2))
  80        continue
c
c           %-----------------------------%
c           | Display computed residuals. |
c           %-----------------------------%
c
            call dmout(6, nconv, 3, rd, maxncv, -6,
     &           'Ritz values (Real, Imag) and relative residuals')
c
         end if
c
c        %------------------------------------------%
c        | Print additional convergence information |
c        %------------------------------------------%
c
         if ( info .eq. 1) then
            print *, ' '
            print *, ' Maximum number of iterations reached.'
            print *, ' '
         else if ( info .eq. 3) then
            print *, ' ' 
            print *, ' No shifts could be applied during implicit
     &                 Arnoldi update, try increasing NCV.'
            print *, ' '
         end if      
c
         print *, ' '
         print *, '_NDRV3 '
         print *, '====== '
         print *, ' '
         print *, ' Size of the matrix is ', n
         print *, ' The number of Ritz values requested is ', nev
         print *, ' The number of Arnoldi vectors generated ',
     &            ' (NCV) is ', ncv
         print *, ' What portion of the spectrum: ', which
         print *, ' The number of converged Ritz values is ', 
     &              nconv 
         print *, ' The number of Implicit Arnoldi update',
     &            ' iterations taken is ', iparam(3)
         print *, ' The number of OP*x is ', iparam(9)
         print *, ' The convergence criterion is ', tol
         print *, ' '
c
      end if
c
 9000 continue
c
      end
c 
c==========================================================================
c
c     matrix vector multiplication subroutine
c
      subroutine av (n, v, w)
      integer           n
      Complex*16            
     &                  v(n), w(n)
c
c     Compute the matrix vector multiplication y<---A*x
c
      print*,'Calling M*E*x'
      imode = 2
      call time_stepper(imode, n, v, w)
      return
      end
c------------------------------------------------------------------------
c     matrix vector multiplication subroutine
c
      subroutine op (n, v, w)
      integer           n
      Complex*16            
     &                  v(n), w(n)
c
c     Compute the matrix vector multiplication y<---inv(M)*A*x
c
      print*,'Calling E*x'
      imode = 3
      call time_stepper(imode, n, v, w)
      return
      end
c------------------------------------------------------------------------
      subroutine mv (n, v, w)
      integer           n
      Complex*16 
     &                  v(n), w(n)
c
c     Compute the matrix vector multiplication y<---M*x
c     where M is the mass matrix
c 
      print*,'Calling M*x'
      imode = 1
      call time_stepper(imode, n, v, w)

      return
      end
c------------------------------------------------------------------------
      subroutine time_stepper(imode, n, v, w)
      integer    imode, n
      complex*16 v(n), w(n)

      integer    fid, i

      n1  = n/2
      fid = 20
      open(fid, file='nek/veci.dat')
      write(fid,*) imode, n1
      write(fid,*)(real(v(i)),    i=1,n1)  ! x velocity
      write(fid,*)(real(v(i+n1)), i=1,n1)  ! y velocity
      write(fid,*)(aimag(v(i)),   i=1,n1)  ! x velocity
      write(fid,*)(aimag(v(i+n1)),i=1,n1)  ! y velocity
      close(fid)

      call system("./runnek.sh")

      open(fid, file='nek/veco.dat', status='old')
c     x velocity component
      do i=1,n1
         read(fid,*) a1, a2
         w(i) = complex(a1,a2)
      enddo
c     y velocity component
      do i=1,n1
         read(fid,*) a1, a2
         w(i+n1) = complex(a1,a2)
      enddo

      close(fid)

      return
      end
