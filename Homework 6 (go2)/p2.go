package main;

import (
    "fmt"
)

func Filter(condition func(int64) bool, collection []int64) []int64 {
    out := make([]int64, 0)

    for _, val := range collection {
        if condition(val) {
            out = append(out, val);
        }
    }

    return out;
}

func Rawr(a int64) bool {return a > 0}

func main() {
    var1 := []int64{3, 4, -2}
    fmt.Print("Initial: ")
    fmt.Println(var1);
    fmt.Print("Filtered by positivity: ")
    fmt.Println(Filter(Rawr, var1))
    fmt.Print("The same variable that was just filtered: ")
    fmt.Println(var1)
}
