package main

import (
    "io/ioutil"
    "os"
    "fmt"
)

var sequences [1048576]int;
var chromosome []byte;
var reverse = []byte{'A', 'C', 'G', 'T'}

func hashChar(c byte) int {
    switch (c) {
        case 'a': fallthrough;
        case 'A': return 0;

        case 'c': fallthrough;
        case 'C': return 1;

        case 'g': fallthrough;
        case 'G': return 2;

        case 't': fallthrough;
        case 'T': return 3;

        default: return 4;
    }
}

func init() {
    if (len(os.Args) != 2) {
        fmt.Println("Expected exactly two arguments!")
        os.Exit(1)
    }
    genes, err := ioutil.ReadFile(os.Args[1]);
    if (err != nil) {
        fmt.Println("Could not read file!")
        os.Exit(2)
    }
    chromosome = genes
}


func runner(seq_number chan int) {
    max_in := uint(len(chromosome) - 10)
    for i := uint(0); i < max_in; i++ {
        handleSeq(i, seq_number)
    }
}

func convertToBaseFour(number int) string {
    byte_slice := make([]byte, 10)

    for i:=uint(9); i >= 0; i-- {
        dividend := 1 << (2*i)
        byte_slice[i] = 65 + reverse[number / dividend];

        number %= dividend;
    }

    return string(byte_slice);
}


// Functions that write the sequence number to the channel
func handleSeq(start uint, seq_number chan<- int) {
    index := 0
    // var sequence int;
    for i := uint(9); i >= 0; i-- {
        val := hashChar(chromosome[start + i])
        if (val > 3) { // Sequence useless
            return;
        } else {
            index += hashChar(chromosome[start + i]) * (1 << (2*i));
        }
    }

    seq_number <- index
}

// Adder function that takes the channels & increments accordingly
func adder(seq_number <-chan int) {
    for {
        sequences[<-seq_number]++
    }
}

func output_results(output *os.File) {
    for i, seq := range sequences {
        output.WriteString(convertToBaseFour(i))
        output.WriteString(" ")
        output.WriteString(string(seq))
        output.WriteString("\n")
    }
}

func main() {

    // fmt.Println(convertToBaseFour(16))
    number := 0

    for i := uint(0); i < 10; i++ {
        x := number / 1 << (2*i);

    }

    chan_seq := make(chan int)
    go adder(chan_seq)
    runner(chan_seq);
    // word_output, _ := os.Create("out.txt")
    // output_results(word_output)
}
