package main;

import (
    "fmt"
)

func Map(effect func(int64) int64, collection []int64) []int64 {
    out := make([]int64, len(collection));

    for i, val := range collection {
        out[i] = effect(val)
    }

    return out;
}

func main() {
    var1 := []int64{3, 4, -2}
    fmt.Print("Initial: ")
    fmt.Println(var1);
    fmt.Print("Multiplied by 7: ")
    fmt.Println(Map(func(a int64) int64 {return a*7}, var1))
    fmt.Print("The same variable that was just filtered: ")
    fmt.Println(var1)

}
