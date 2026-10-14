package main

import "core:fmt"
import "core:math/rand"

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

DECK_SIZE :: 52

Deck :: struct {
    cards: [DECK_SIZE]Card,
    next: int,
}

Hand :: struct {
    cards: [DECK_SIZE]Card,
    count: int
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

main :: proc() {
    hand: Hand
    
    ace := Card{suit = .Hearts, rank = .Ace}
    ok := add_card(&hand, ace)
    assert(ok)

    fmt.println("Stored cards:", hand.count)
    print_cards(hand.cards[:hand.count])
}  