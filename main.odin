package main

import "core:fmt"

Suit :: enum {
    Hearts,
    Diamonds,
    Clubs,
    Spades
}

Rank :: enum {
    Ace = 1,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    Ten,
    Jack,
    Queen,
    King
}

Card :: struct {
    suit: Suit,
    rank: Rank
}

is_ace :: proc(card: Card) -> bool {
    return card.rank == .Ace
}

same_rank :: proc(card: Card, card_to_compare: Card) -> bool {
    return card.rank == card_to_compare.rank
}

suit_name :: proc(suit: Suit) -> string {
    name := "Unknown Suit"

    switch suit {
        case .Hearts:
            name = "Hearts"
        case .Diamonds:
            name = "Diamonds"
        case .Clubs:
            name = "Clubs"
        case .Spades:
            name = "Spades"
    }

    return name
}

rank_name :: proc(rank: Rank) -> string {
    name := "Unknown Rank"

    switch rank {
        case .Ace: name = "Ace"
        case .Two: name = "Two"
        case .Three: name = "Three"
        case .Four: name = "Four"
        case .Five: name = "Five"
        case .Six: name = "Six"
        case .Seven: name = "Seven"
        case .Eight: name = "Eight"
        case .Nine : name = "Nine"
        case .Ten : name = "Ten"
        case .Jack : name = "Jack"
        case .Queen : name = "Queen"
        case .King : name = "King"
    }

    return name
}

print_card :: proc(card: Card) {
    fmt.printf("%s of %s\n", rank_name(card.rank), suit_name(card.suit))
}

main :: proc() {
    fmt.println("==========================")
    fmt.println("        BLACKJACK         ")
    fmt.println("==========================")
    fmt.println()
    fmt.println("Welcome to the table!")
    fmt.println("Let's play some cards.")
    fmt.println()

    first := Card{
        suit = .Spades,
        rank = .Ace,
    }
    second := Card{
        suit = .Hearts,
        rank = .King,
    }

    print_card(first)
    print_card(second)
    fmt.println()
    fmt.println("First card is an ace:", is_ace(first))
    fmt.println("Second card is an ace:", is_ace(second))
    fmt.println("Same rank:", same_rank(first, second))
}