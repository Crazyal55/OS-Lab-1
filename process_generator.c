#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(void) {
    pid_t pid;

    // Print the PID of the current (parent) process before forking.
    printf("Parent process PID: %d\n", getpid());

    // Create a new child process.
    pid = fork();

    // Check if fork failed.
    if (pid < 0) {
        perror("fork failed");
        return 1;
    }

    // Code executed by the child process.
    if (pid == 0) {
        printf("Child running with PID: %d\n", getpid());

        // Keep the child alive for 120 seconds.
        sleep(120);
    } else {
        // Code executed by the parent process.
        printf("Parent waiting...\n");

        // Wait for the child process to finish.
        wait(NULL);
    }

    return 0;
}
