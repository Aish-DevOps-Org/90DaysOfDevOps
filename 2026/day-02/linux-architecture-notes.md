**The core components of Linux (kernel, user space, init/systemd)**
Application -> App or user 
Shell -> Interface for user to interact with OS
Kernel -> Heart of the linux. this coverts user inputs to machine language and talks to the hardware.
Hardware -> Where the OS is working
init/systemd -> It is the first process which kernel starts during the boot sequence.
-> PID - 1.
-> Parent process of all the system process.
-> PRIMARY FUNCTION IS TO BRIMG THE SYSTEM IN THE USABLE STATE.

**How processes are created and managed**
In Linux, every instance running is a process and is assigned a unique process ID. 
Linux follows a two-step approach for process creation using system calls:
1. fork()
- A running process (parent) uses the fork() system call to create an almost exact, but independent, copy of itself (child process).
- The child process gets its own unique PID but inherits the parent's memory space, file descriptors, and environment variables.
- The fork() call returns the child's PID to the parent process and 0 to the child process, allowing the program to execute different code paths in the parent and child.

2. exec()
- The child process then typically uses an exec() system call to replace its current memory image with a new program.
- The PID remains the same, but the process now runs a new set of instructions.

**What systemd does and why it matters**
-> First process: The kernel launches the init program as its final step, after which it takes over the initialization of user space.
-> Process Management: is responsible for starting and stopping all other essential system services and background processes.
-> Orphaned Adoption: If any parent process is stopped before its child, then the child is automatically adopted by init to ensure it is properly managed until it is finished.
-> shutdown: It ensures that the services are stopped gracefully before the system halts or reboots. 

**process states** (running, sleeping, zombie, etc.)
1. running (R) - the process is currently being executed or waiting to be executed. 
2. interruptible sleep (S) - most common sleeping state, the process is waiting for an event or resource and can be awakened by a signal. 
3. Uninterruptible sleep (D) - the process is waiting for a critical operation to complete and cannot be awakened by a signal, even a SIGKILL. Process waiting on this state mostly means that there is a problem with the hardware or kernel. 
4. Stopped (T) - process has been suspended by our job control signal. 
5. Zombie (Z) - the process has terminated, but its entry is still present in the process table. It is waiting for its parent process to read its exit status using the wait() system call, and the entry will be removed once the parent 'reaps' it. 

- **5 commands** I will use daily
1. touch -> create a new empty file\
2. mkdir -> create empty directory
3. vim -> edit the file'
4. rm -> delete the file
5. ps -> check active process
