package main

import (
	"flag"
	"fmt"
	"sync"
	"time"
)

func OutputFibonacci(n int, wg *sync.WaitGroup, noOutput bool) {
	x, y := 0, 1

	for i := 0; i <= n; i++ {
		x, y = y, x+y
		if !noOutput {
			fmt.Println(x)
		}
	}

	wg.Done()
}

func main() {
	numbers := flag.Int("number", 2000000, "Number for fibonacci test")
	tasks := flag.Int("tasks", 10, "The number of tasks for fibonacci test")
	noOutput := flag.Bool("no-output", false, "Don't output fibonacci result to stdout")
	flag.Parse()

	s := time.Now()
	wg := sync.WaitGroup{}
	wg.Add(*tasks)

	for i := 0; i < *tasks; i++ {
		go OutputFibonacci(*numbers, &wg, *noOutput)
	}

	wg.Wait()
	fmt.Printf("costs %s", time.Since(s))
}
