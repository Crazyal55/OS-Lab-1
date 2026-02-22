#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(void) {
    pid_t pid;

    // Print the PID of the current (parent) process before forking.
    fprintf(stderr, "=== Process Generator Starting ===\n");
    printf("Parent process PID: %d\n", getpid());
    fflush(stdout);  // Force output to display

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
        fflush(stdout);  // Force output to display

        // Keep the child alive for 120 seconds.
        sleep(120);
    } else {
        // Code executed by the parent process.
        printf("Parent waiting...\n");
        fflush(stdout);  // Force output to display

        // Wait for the child process to finish.
        wait(NULL);
    }

    return 0;
}
