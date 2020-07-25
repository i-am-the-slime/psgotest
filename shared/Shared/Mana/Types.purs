module Mana.Types where

import Data.Maybe (Maybe(..))

data ManaSymbol
  = Mana0
  | Mana10
  | Mana12
  | Mana14
  | Mana16
  | Mana18
  | Mana2
  | Mana2B
  | Mana2R
  | Mana2W
  | Mana4
  | Mana6
  | Mana8
  | ManaB
  | ManaBP
  | ManaC
  | ManaGP
  | ManaGW
  | ManaRG
  | ManaRW
  | ManaU
  | ManaUP
  | ManaW
  | ManaWP
  | ManaX
  | Mana1
  | Mana11
  | Mana13
  | Mana15
  | Mana17
  | Mana19
  | Mana20
  | Mana2G
  | Mana2U
  | Mana3
  | Mana5
  | Mana7
  | Mana9
  | ManaBG
  | ManaBR
  | ManaG
  | ManaGU
  | ManaR
  | ManaRP
  | ManaS
  | ManaUB
  | ManaUR
  | ManaWB
  | ManaWU

manaSymbolToString :: ManaSymbol -> String
manaSymbolToString = case _ of
  Mana0 -> "0"
  Mana10 -> "10"
  Mana12 -> "12"
  Mana14 -> "14"
  Mana16 -> "16"
  Mana18 -> "18"
  Mana2 -> "2"
  Mana2B -> "2B"
  Mana2R -> "2R"
  Mana2W -> "2W"
  Mana4 -> "4"
  Mana6 -> "6"
  Mana8 -> "8"
  ManaB -> "B"
  ManaBP -> "BP"
  ManaC -> "C"
  ManaGP -> "GP"
  ManaGW -> "GW"
  ManaRG -> "RG"
  ManaRW -> "RW"
  ManaU -> "U"
  ManaUP -> "UP"
  ManaW -> "W"
  ManaWP -> "WP"
  ManaX -> "X"
  Mana1 -> "1"
  Mana11 -> "11"
  Mana13 -> "13"
  Mana15 -> "15"
  Mana17 -> "17"
  Mana19 -> "19"
  Mana20 -> "20"
  Mana2G -> "2G"
  Mana2U -> "2U"
  Mana3 -> "3"
  Mana5 -> "5"
  Mana7 -> "7"
  Mana9 -> "9"
  ManaBG -> "BG"
  ManaBR -> "BR"
  ManaG -> "G"
  ManaGU -> "GU"
  ManaR -> "R"
  ManaRP -> "RP"
  ManaS -> "S"
  ManaUB -> "UB"
  ManaUR -> "UR"
  ManaWB -> "WB"
  ManaWU -> "WU"
