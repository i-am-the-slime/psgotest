module Card.Component where

import Prelude
import Cards.Types (Card)
import Control.Alt ((<|>))
import Data.Array (fromFoldable, intercalate)
import Data.Either (Either(..))
import Data.List (List, many)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (Pattern(..), split)
import Effect (Effect)
import Mana.Types (ManaSymbol(..), manaSymbolToString)
import React.Basic (JSX, element)
import React.Basic.DOM (CSS, css)
import React.Basic.DOM as R
import React.Basic.Hooks (ReactComponent, component, fragment)
import React.Basic.Hooks as React
import React.JSS (createUseStyles_)
import Text.Parsing.Parser (ParseError, ParserT, parseErrorMessage, runParser)
import Text.Parsing.Parser.Combinators (between) as PC
import Text.Parsing.Parser.String (string) as PC

fromMaybeFlipped ∷ ∀ a. Maybe a -> a -> a
fromMaybeFlipped = flip fromMaybe

infixl 7 fromMaybeFlipped as |||

newlinesToBr ∷ String -> Array JSX
newlinesToBr text = intercalate [ R.br {} ] ((pure <<< R.text) <$> (split (Pattern "\n") text))

cardStyles ∷
  { card ∷ CSS
  , cardTitle ∷ CSS
  , croppedImg ∷ CSS
  , powerToughness ∷ CSS
  }
cardStyles =
  { card:
    css
      { display: "grid"
      , border: "10px solid #040404"
      , borderRadius: "22px"
      , width: "315px"
      , height: "440px"
      , paddingLeft: "10px"
      , minWidth: 0
      , minHeight: 0
      }
  , croppedImg:
    css
      { backgroundSize: "cover"
      , width: "295px"
      , height: "201px"
      }
  , cardTitle:
    css
      { display: "flex"
      , alignItems: "center"
      , overflow: "hidden"
      , minWidth: "0"
      }
  , powerToughness:
    css
      { fontSize: "1.7em"
      }
  }

mkCard ∷ Effect (ReactComponent { card ∷ Card })
mkCard = do
  manaCost <- mkManaCost
  useStyles <- createUseStyles_ cardStyles
  component "Card" \{ card } -> React.do
    classes <- useStyles
    pure
      $ R.div
          { className: classes.card --"card"
          , children:
            [ R.div
                { className: classes.cardTitle
                , children:
                  [ R.h1_ [ R.text card.name ]
                  , element manaCost { manaCost: card.mana_cost }
                  ]
                }
            , R.img { className: classes.croppedImg, src: (card.image_uris <#> _.art_crop) ||| "" }
            , R.p_ (card.oracle_text ||| "" # newlinesToBr)
            , renderPowerToughness classes.powerToughness card
            ]
          }

manaCostClasses ∷ { cardTitleMana ∷ CSS }
manaCostClasses =
  { cardTitleMana:
    css
      { width: "2em"
      , height: "2em"
      , marginLeft: "0.1em"
      , marginRight: "0.1em"
      }
  }

mkManaCost ∷ Effect (ReactComponent { manaCost ∷ Maybe String })
mkManaCost = do
  manaSymbol <- mkManaSymbol
  useStyles <- createUseStyles_ manaCostClasses
  component "ManaCost" \{ manaCost } -> React.do
    classes <- useStyles
    pure $ fragment
      $ case parseManaCost <$> manaCost of
          Nothing -> mempty
          Just (Left e) -> [ R.text $ parseErrorMessage e <> " " <> show manaCost ]
          Just (Right (mss ∷ List ManaSymbol)) ->
            fromFoldable mss
              <#> \ms -> element manaSymbol { className: classes.cardTitleMana, manaSymbol: ms }

renderPowerToughness ∷ String -> Card -> JSX
renderPowerToughness className card =
  fromMaybe mempty ado
    p <- card.power
    t <- card.toughness
    in R.div
      { className
      , children: [ R.text $ p <> "/" <> t ]
      }

mkManaSymbol ∷ Effect (ReactComponent { className ∷ String, manaSymbol ∷ ManaSymbol })
mkManaSymbol = do
  component "ManaSymbol" \({ className, manaSymbol }) -> React.do
    let
      manaString = manaSymbolToString manaSymbol
    pure
      $ R.img
          { src: "/assets/svg/mana/" <> manaString <> ".svg"
          , alt: manaString
          , className
          }

curlies ∷ ∀ m a. Monad m => ParserT String m a -> ParserT String m a
curlies = PC.between (PC.string "{") (PC.string "}")

parseManaCost ∷ String -> Either ParseError (List ManaSymbol)
parseManaCost s = runParser s (many (curlies manaSymbolsParser))

manaSymbolsParser ∷ ∀ m. Monad m => ParserT String m ManaSymbol
manaSymbolsParser =
  (PC.string "10" <#> const Mana10)
    <|> (PC.string "11" <#> const Mana11)
    <|> (PC.string "12" <#> const Mana12)
    <|> (PC.string "13" <#> const Mana13)
    <|> (PC.string "14" <#> const Mana14)
    <|> (PC.string "15" <#> const Mana15)
    <|> (PC.string "16" <#> const Mana16)
    <|> (PC.string "17" <#> const Mana17)
    <|> (PC.string "18" <#> const Mana18)
    <|> (PC.string "19" <#> const Mana19)
    <|> (PC.string "20" <#> const Mana20)
    <|> (PC.string "0" <#> const Mana0)
    <|> (PC.string "1" <#> const Mana1)
    <|> (PC.string "2" <#> const Mana2)
    <|> (PC.string "3" <#> const Mana3)
    <|> (PC.string "4" <#> const Mana4)
    <|> (PC.string "5" <#> const Mana5)
    <|> (PC.string "6" <#> const Mana6)
    <|> (PC.string "7" <#> const Mana7)
    <|> (PC.string "8" <#> const Mana8)
    <|> (PC.string "9" <#> const Mana9)
    <|> (PC.string "B/G" <#> const ManaBG)
    <|> (PC.string "B/R" <#> const ManaBR)
    <|> (PC.string "U/B" <#> const ManaUB)
    <|> (PC.string "U/R" <#> const ManaUR)
    <|> (PC.string "W/B" <#> const ManaWB)
    <|> (PC.string "W/U" <#> const ManaWU)
    <|> (PC.string "2/B" <#> const Mana2B)
    <|> (PC.string "2/R" <#> const Mana2R)
    <|> (PC.string "2/W" <#> const Mana2W)
    <|> (PC.string "G/P" <#> const ManaGP)
    <|> (PC.string "G/W" <#> const ManaGW)
    <|> (PC.string "R/G" <#> const ManaRG)
    <|> (PC.string "R/W" <#> const ManaRW)
    <|> (PC.string "U/P" <#> const ManaUP)
    <|> (PC.string "W/P" <#> const ManaWP)
    <|> (PC.string "2/G" <#> const Mana2G)
    <|> (PC.string "2/U" <#> const Mana2U)
    <|> (PC.string "B/P" <#> const ManaBP)
    <|> (PC.string "R/P" <#> const ManaRP)
    <|> (PC.string "G/U" <#> const ManaGU)
    <|> (PC.string "B" <#> const ManaB)
    <|> (PC.string "U" <#> const ManaU)
    <|> (PC.string "W" <#> const ManaW)
    <|> (PC.string "G" <#> const ManaG)
    <|> (PC.string "R" <#> const ManaR)
    <|> (PC.string "X" <#> const ManaX)
    <|> (PC.string "C" <#> const ManaC)
    <|> (PC.string "S" <#> const ManaS)
