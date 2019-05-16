/*
 * Copyright 2019 Tais P. Hansen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

package main

import (
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"syscall"

	"golang.org/x/sys/unix"
)

func main() {
	ch := make(chan os.Signal, 2)
	signal.Notify(ch)

	pid := -1
	go func(pid *int, ch chan os.Signal) {
		for {
			sig := <-ch
			switch sig {
			case unix.SIGCHLD:
				reap()
			}
			err := unix.Kill(*pid, sig.(syscall.Signal))
			if err != nil {
				panic(err)
			}
		}
	}(&pid, ch)

	cmd := exec.Command(os.Args[1], os.Args[2:]...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Start(); err != nil {
		panic(err)
	}
	pid = cmd.Process.Pid

	if err := cmd.Wait(); err != nil {
		fmt.Println(err)
	}
}

func reap() {
	var waitstatus unix.WaitStatus
	var rusage unix.Rusage
	for {
		wpid, err := unix.Wait4(-1, &waitstatus, unix.WNOHANG, &rusage)
		if err != nil {
			panic(err)
		}
		if wpid <= 0 {
			break
		}
	}
}
