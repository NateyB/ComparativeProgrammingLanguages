package main

import (
 "flag"
 "strings"
 "strconv"
 "math/rand"
 "os"
)

var m = make(map[string]int)

/*
1) Motifs must be the active sub-region
2) Lengths of motifs must be less than the lengths of the active subregion
*/

type thingSeq struct {
    sequence []rune
    mot_indices []int
    start_indices []int
}

type motifResult struct {
    sequence []rune
    index int
}

var SEQUENCE_LENGTH, NUMBER_SEQUENCES, MINIMUM_MOTIFS, ACTIVE_REGION int
var MOTIF_LENGTHS = []int{}
var MUTATION_NUMBERS = []int{}
var LETTERS = []rune{'A', 'T', 'C', 'G'}
var TEMPLATES = [][]rune{}

func gen_templates() {
    for _, k := range MOTIF_LENGTHS {
        cur_template := []rune{}
        for i := 0; i < k; i++ {
            cur_template = append(cur_template, LETTERS[rand.Intn(4)])
        }
        TEMPLATES = append(TEMPLATES, cur_template)
    }
}

func init() {
    var mot_lens, mut_nums string
    flag.IntVar(&SEQUENCE_LENGTH, "l", 250, "The length of a sequence.")
    flag.IntVar(&NUMBER_SEQUENCES, "n", 100, "The number of sequences to generate.")
    flag.StringVar(&mot_lens, "ks", "10 19 22 27 15 38", "A list of motif lengths separated by spaces.")
    flag.StringVar(&mut_nums, "cs", "0 1 2 3 4 5", "A list of the number of motif mutations per motif separated by spaces.")
    flag.IntVar(&MINIMUM_MOTIFS, "m", 2, "The minimum number of motifs.")
    flag.IntVar(&ACTIVE_REGION, "I", 150, "Length of the active sub-region in the sequence.")

    flag.Parse()

    motif_lengths := strings.Split(mot_lens, " ")
    mutation_nums := strings.Split(mut_nums, " ")
    for _, i := range motif_lengths {
        j, _ := strconv.Atoi(i)
        MOTIF_LENGTHS = append(MOTIF_LENGTHS, j)
    }
    for _, i := range mutation_nums {
        j, _ := strconv.Atoi(i)
        MUTATION_NUMBERS = append(MUTATION_NUMBERS, j)
    }

    gen_templates()
}

func main() {
    sequences := make([]thingSeq, 0)
    chan_motif := make(chan motifResult)
    chan_inter := make(chan rune)

    go gen_motifs(chan_motif);
    go gen_letters(chan_inter);

    for i := 0; i < NUMBER_SEQUENCES; i++ {
        sequences = append(sequences, gen_seq(chan_motif, chan_inter))
    }

    template_file, _ := os.Create("out.txt")
    seq_file, _ := os.Create("seq.dat")

    output_temps(TEMPLATES, template_file)
    output_seq(sequences, seq_file)
}

func output_temps(sequences [][]rune, output *os.File) {
    for _, temp := range sequences {
        temp = append(temp, '\n')
        output.WriteString(string(temp))
    }
}

func output_seq(sequences []thingSeq, output *os.File) {
    for i, seq := range sequences {
        output.WriteString(">seq")
        output.WriteString(strconv.Itoa(i))
        output.WriteString(" ")
        for j, mot := range seq.mot_indices {
            output.WriteString("m")
            output.WriteString(strconv.Itoa(mot))
            output.WriteString(" ")
            start := seq.start_indices[j]
            output.WriteString(strconv.Itoa(start))
            output.WriteString(" ")
            output.WriteString(strconv.Itoa(start + MOTIF_LENGTHS[mot] - 1))
            output.WriteString(" ")
        }
        output.WriteString("\n")
        output.WriteString(string(seq.sequence))
        output.WriteString("\n")
    }
}

/*
1) Construct the sequence
    * Ensure that there's enough space to fit the motif; if not, toss it
2) Check the minimum number of motifs
3) Check the motifs are all contained within the active subregion
4) If either 2 or 3 fails, restart
*/
func gen_seq(motifs <-chan motifResult, inters <-chan rune) thingSeq {
    mot_needed := MINIMUM_MOTIFS
    seq := make([]rune, 0)
    motif_list := make([][]rune, 0)
    motif_inds := make([]int, 0) // Starting indices in the sequence
    motif_indices := make([]int, 0)
    var index int = 0

    for (index < SEQUENCE_LENGTH) {
        select {
            case motif:=<-motifs:
                if (len(motif.sequence) > SEQUENCE_LENGTH - index) {
                    break; // Too long
                }
                motif_list = append(motif_list, motif.sequence)
                motif_inds = append(motif_inds, index)
                motif_indices = append(motif_indices, motif.index)
                mot_needed--;
                seq = append(seq, motif.sequence...)
                index += len(motif.sequence)

            case letter:=<-inters:
                seq = append(seq, letter)
                index++
        }
    }

    if mot_needed > 0 || motif_inds[len(motif_inds) - 1] + len(motif_list[len(motif_inds) - 1]) - motif_inds[0] > ACTIVE_REGION {
        return gen_seq(motifs, inters)
    }

    return thingSeq{sequence: seq, mot_indices: motif_indices, start_indices: motif_inds}
}

func gen_letters(inters chan<- rune) {
    for {
        inters <- LETTERS[rand.Intn(len(LETTERS))]
    }
}

func get_index(item rune, seq []rune) int {
    for i, v := range seq {
        if (v == item) {
            return i
        }
    }
    return -1
}

func gen_motifs(result chan<- motifResult) {
    for {
        index := rand.Intn(len(TEMPLATES))
        sel_template := make([]rune, len(TEMPLATES[index]))
        copy(sel_template, TEMPLATES[index])
        num_mutes := MOTIF_LENGTHS[index]
        for i := 0; i < num_mutes; i++ {
            rep_i := len(sel_template) - 1 - i
            char_i := get_index(sel_template[rep_i], LETTERS)
            char_n := rand.Intn(len(LETTERS))
            for (char_i == char_n) {
                char_n = rand.Intn(len(LETTERS))
            }

            sel_template[rep_i] = LETTERS[char_n]
        }

        result <- motifResult{sequence: sel_template, index: index}
    }
}
