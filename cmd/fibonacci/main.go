package main

import (
	"flag"
	"fmt"
	"sync"
	"time"
)

func OutputFibonacci(n int, wg *sync.WaitGroup) {
	x, y := 0, 1

	for i := 0; i <= n; i++ {
		x, y = y, x+y
		fmt.Println(x)
	}

	wg.Done()
}

func main() {
	n := flag.Int("number", 2000000, "Number for fibonacci test")
	t := flag.Int("tasks", 10, "Task number for fibonacci test")
	flag.Parse()

	s := time.Now()
	wg := sync.WaitGroup{}
	wg.Add(*t)

	for i := 0; i < *t; i++ {
		go OutputFibonacci(*n, &wg)
	}

	wg.Wait()
	fmt.Printf("costs %s", time.Since(s))
}
