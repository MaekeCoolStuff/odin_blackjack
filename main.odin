package main

import "core:fmt"
import "core:math/rand"
import "core:strings"
import "core:os"
import "core:io"

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

Action :: enum {
    Hit,
    Stand,
    Quit,
    Invalid
}

Turn_Result :: enum {
    Stood,
    Natural,
    Twenty_One,
    Bust,
    Quit,
    Input_End,
    Input_Failed,
    Deal_Failed
}

Read_Status :: enum {
    Ok,
    End,
    Too_Long,
    Failed
}

Card :: struct {
    suit: Suit,
    rank: Rank
}

DECK_SIZE :: 52

Deck :: struct {
    cards: [DECK_SIZE]Card,
    next: int,
}

Hand :: struct {
    cards: [DECK_SIZE]Card,
    count: int
}

Score :: struct {
    total: int,
    soft: bool
}

new_deck :: proc() -> Deck {
    deck := Deck{
        cards = build_deck()
    }
    shuffle(deck.cards[:])
    return deck
}

build_deck :: proc() -> [DECK_SIZE]Card {
    deck: [DECK_SIZE]Card
    next := 0

    for suit in Suit {
        for rank in Rank {
            assert(next < len(deck))
            deck[next] = Card{
                suit = suit,
                rank = rank,
            }
            next += 1
        }
    }

    assert(next == len(deck))
    return deck
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

count_card :: proc(cards: []Card, wanted: Card) -> int {
    count := 0
    for card in cards {
        if card.suit == wanted.suit && card.rank == wanted.rank {
            count += 1
        }
    }
    return count
}

check_standard_deck :: proc(cards: []Card) {
    assert(len(cards) == DECK_SIZE)

    for suit in Suit {
        for rank in Rank {
            wanted := Card{
                suit = suit,
                rank = rank
            }
            assert(count_card(cards, wanted) == 1)
        }
    }
}

print_card :: proc(card: Card) {
    fmt.printf("%s of %s\n", rank_name(card.rank), suit_name(card.suit))
}

print_cards :: proc(cards: []Card) {
    for card in cards {
        print_card(card)
    }
}

shuffle :: proc(cards: []Card) {
    for indexToSwapTo := len(cards) -1; indexToSwapTo > 0; indexToSwapTo -= 1 {
        cardToSwap := rand.int_max(indexToSwapTo + 1)
        cards[indexToSwapTo], cards[cardToSwap] = cards[cardToSwap], cards[indexToSwapTo]
    }
}

advance_once :: proc(deck : ^Deck) {
    deck.next += 1
}

draw :: proc(deck: ^Deck) -> (Card, bool) {
    if deck.next >= len(deck.cards) {
        return Card{}, false
    }

    card := deck.cards[deck.next]
    deck.next += 1
    return card, true
}

add_card :: proc(hand: ^Hand, card: Card) -> bool {
    if hand.count >= len(hand.cards) {
        return false
    }

    hand.cards[hand.count] = card
    hand.count += 1
    return true
}

deal_to :: proc(deck: ^Deck, hand: ^Hand) -> bool {
    if hand.count >= len(hand.cards) {
        return false
    }

    card, ok := draw(deck)
    if !ok {
        return false
    }
    return add_card(hand, card)
}

score :: proc(cards: []Card) -> Score {
    total, aces := 0, 0
    for card in cards {
        switch card.rank {
            case .Ace:
                total += 11
                aces += 1
            case .Two: total += 2
            case .Three: total += 3
            case .Four: total += 4
            case .Five: total += 5
            case .Six: total += 6
            case .Seven: total += 7
            case .Eight: total += 8
            case .Nine: total += 9
            case .Ten: total += 10
            case .Jack, .Queen, .King:
                total += 10
        }
    }

    for total > 21 && aces > 0 {
        total -= 10
        aces -= 1
    }
    return Score{total = total, soft = aces > 0}
}

hand_score :: proc(hand: Hand) -> Score {
    local := hand
    return score(local.cards[:local.count])
}

is_blackjack :: proc(hand: Hand) -> bool {
    return hand.count == 2 && hand_score(hand).total == 21
}

show_hand :: proc(label: string, hand: Hand) {
    local := hand
    fmt.println(label)
    print_cards(local.cards[:local.count])
    value := hand_score(hand)
    fmt.println("Total:", value.total, "Soft:", value.soft)
}

play_player_turn :: proc(deck: ^Deck, hand: ^Hand) -> Turn_Result {
    for {
        show_hand("Your hand:", hand^)
        value := hand_score(hand^)

        if is_blackjack(hand^) {
            return .Natural
        }
        if value.total > 21 {
            return .Bust
        }
        if value.total == 21 {
            return .Twenty_One
        }

        action, status := read_action()
        if status == .End {
            return .Input_End
        }
        if status == .Failed {
            return .Input_Failed
        }
        
        switch action {
            case .Hit:
                if !deal_to(deck, hand) {
                    return .Deal_Failed
                }
            case .Stand:
                return .Stood
            case .Quit:
                return .Quit
            case .Invalid:
                continue
        }
    }
}

parse_action :: proc(text: string) -> Action {
    switch strings.trim_space(text) {
        case "h", "H", "hit", "HIT":
            return .Hit
        case "s", "S", "stand", "STAND":
            return .Stand
        case "q", "Q", "quit", "QUIT":
            return .Quit
    }
    return .Invalid
}

read_line :: proc(buffer: []u8) -> (string, Read_Status) {
    used := 0
    too_long := false
    byte: [1]u8

    for {
        n, err := os.read(os.stdin, byte[:]) 
        if n == 0 {
            if err != nil && err != io.Error.EOF {
                return " ", .Failed
            }
            if too_long {
                return " ", .Too_Long
            }
            if used == 0 {
                return " ", .End
            }
            return string(buffer[:used]), .Ok
        }
        if err != nil && err != io.Error.EOF {
            return  "", .Failed
        }

        if byte[0] == '\n' {
            break
        }
        if byte[0] == '\r' {
            continue
        }
        if used < len(buffer) {
            buffer[used] = byte[0]
            used += 1
        } else {
            too_long = true
        }
    }

    if too_long {
        return "", .Too_Long
    }
    return string(buffer[:used]), .Ok
}

read_action :: proc() -> (Action, Read_Status) {
    buffer: [96]u8
    for {
        fmt.print("(H)it, (S)tand, or (Q)uit: ")
        text, status := read_line(buffer[:])
        switch status {
            case .End, .Failed:
                return .Invalid, status
            case .Too_Long:
                fmt.println("Please use a shorter command.")
                continue
            case .Ok:
        }

        action := parse_action(text)
        if action != .Invalid {
            return action, .Ok
        }
        fmt.println("Choose hit, stand, or quit.")
    }
}

main :: proc() {
    deck := new_deck()
    check_standard_deck(deck.cards[:])
    hand: Hand
    for number := 0; number < 2; number += 1 {
        ok := deal_to(&deck, &hand)
        if !ok {
            fmt.println("Could not deal an opening hand.")
            return
        }
    }

    result := play_player_turn(&deck, &hand)
    switch result {
        case .Stood:
            fmt.println("You stand.")
        case .Natural:
            fmt.println("Natural Blackjack!")
        case .Twenty_One:
            fmt.println("Twenty-one. Your turn is complete.")
        case .Bust:
            fmt.println("Bust. Your turn is complete.")
        case .Quit:
            fmt.println("You quit the session.")
        case .Input_End:
            fmt.println("Input ended. Session Closed.")
        case .Input_Failed:
            fmt.println("Could not read input. Session Closed.")
        case .Deal_Failed:
            fmt.println("Could not deal another card.")
    }
    
}  