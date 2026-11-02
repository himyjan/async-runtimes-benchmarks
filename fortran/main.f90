program bench

use omp_lib
implicit none

integer :: num_tasks = 100000
character(len=32) :: num_tasks_str

if (command_argument_count() > 0) then
    call get_command_argument(1, num_tasks_str)
    read(num_tasks_str, *) num_tasks
end if

! OpenMP parallel region — each thread sleeps 10 seconds.
! The implicit barrier at !$omp end parallel waits for all threads.
!$omp parallel num_threads(num_tasks)
    call sleep(10)
!$omp end parallel

print *, 'All tasks completed'

end program bench
