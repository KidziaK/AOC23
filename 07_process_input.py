import argparse

from pathlib import Path
from collections import Counter
from dataclasses import dataclass
from enum import Enum

import numpy as np

class Combination(Enum):
    HIGH_CARD = 0
    ONE_PAIR = 1
    TWO_PAIR = 2
    TRIPLE = 3
    FULL_HOUSE = 4
    FOUR_OF_A_KIND = 5
    FIVE_OF_A_KIND = 6


@dataclass
class Hand:
    cards: str
    bid: int
    suit_mapping = {
        "2": 2,
        "3": 3,
        "4": 4,
        "5": 5,
        "6": 6,
        "7": 7,
        "8": 8,
        "9": 9,
        "T": 10,
        "J": 1,
        "Q": 12,
        "K": 13,
        "A": 14,
    }

    def strength(self) -> int:
        non_jack_cards = [c for c in self.cards if c != "J"]
        num_jacks = 5 - len(non_jack_cards)
        c = Counter(non_jack_cards)
        buckets = c.most_common()

        if num_jacks == 5: return Combination.FIVE_OF_A_KIND.value
        elif num_jacks == 4: return Combination.FIVE_OF_A_KIND.value
        elif num_jacks == 3:
            if len(buckets) == 1: return Combination.FIVE_OF_A_KIND.value
            elif len(buckets) == 2: return Combination.FOUR_OF_A_KIND.value
        elif num_jacks == 2:
            if len(buckets) == 1: return Combination.FIVE_OF_A_KIND.value
            elif len(buckets) == 2: return Combination.FOUR_OF_A_KIND.value
            elif len(buckets) == 3: return Combination.TRIPLE.value
        elif num_jacks == 1:
            if len(buckets) == 1: return Combination.FIVE_OF_A_KIND.value
            elif len(buckets) == 2: 
                if buckets[0][1] == 2: return Combination.FULL_HOUSE.value
                else: return Combination.FOUR_OF_A_KIND.value      
            elif len(buckets) == 3: return Combination.TRIPLE.value
            elif len(buckets) == 4: return Combination.ONE_PAIR.value
        else:
            if len(buckets) == 1: return Combination.FIVE_OF_A_KIND.value
            elif len(buckets) == 2: 
                if buckets[0][1] == 1 or buckets[0][1] == 4: return Combination.FOUR_OF_A_KIND.value    
                else: return Combination.FULL_HOUSE.value   
            elif len(buckets) == 3: 
                if buckets[0][1] == 2 or buckets[1][1] == 2: return Combination.TWO_PAIR.value    
                else: return Combination.TRIPLE.value  
            elif len(buckets) == 4: return Combination.ONE_PAIR.value
            else: return Combination.HIGH_CARD.value

            
    def __lt__(self, other: "Hand") -> bool:
        s1, s2, = self.strength(), other.strength()
        if s1 > s2: return False
        elif s1 < s2: return True
        for i in range(5):
            v1, v2 = self.suit_mapping[self.cards[i]], self.suit_mapping[other.cards[i]]
            if v1 > v2: return False
            elif v1 < v2: return True
        return False # hands are the same




parser = argparse.ArgumentParser()
parser.add_argument("file_name", default="07_input_simple.txt", nargs="?")
args = parser.parse_args()
file_name = args.file_name

hands = []

with Path(file_name).open("r") as file:
    for line in file.readlines():
        cards, bid, *_ = line.strip().split(" ")
        hands.append(Hand(cards, bid))

hands.sort(key=lambda hand: hand)


with Path(file_name.replace(".txt", "_sorted.txt")).open("w+") as file:
    for i, h in enumerate(hands):
        delim = "\n"
        if i == len(hands) - 1: delim = ""
        file.write(h.cards + " " + str(h.bid) + delim)