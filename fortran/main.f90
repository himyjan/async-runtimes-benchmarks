program bench

use omp_lib
implicit none

integer :: num_tasks = 100000
integer :: num_threads
character(len=32) :: num_tasks_str

if (command_argument_count() > 0) then
    call get_command_argument(1, num_tasks_str)
    read(num_tasks_str, *) num_tasks
end if

! Fixed thread pool — 1000 OpenMP threads, not one per task
num_threads = min(num_tasks, 1000)

!$omp parallel num_threads(num_threads)
!$omp do
    do i = 1, num_tasks
        call sleep(10)
    end do
!$omp end do
!$omp end parallel

print *, 'All tasks completed'

end program bench
