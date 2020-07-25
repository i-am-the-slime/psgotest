module Cards.Service where

import Prelude hiding (between)

import Cards.Types (CardRepo, Card)
import Control.Alt ((<|>))
import Data.Array (replicate)
import Data.Either (Either, either)
import Data.Foldable (class Foldable, fold, foldr)
import Data.List (many)
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Semigroup.Foldable (intercalateMap)
import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Class.Console (log)
import Foreign (renderForeignError)
import Partial.Unsafe (unsafeCrashWith)
import Prim.Row (class Nub, class Union)
import Record (disjointUnion)
import Simple.JSON (class ReadForeign, class WriteForeign, readJSON)
import Simple.JSON as JSON
import Text.Parsing.Parser (ParseError, ParserT, runParser)
import Text.Parsing.Parser.Combinators (between)
import Text.Parsing.Parser.String (class StringLike, string)

parseAndSaveCards ∷ ∀ ctx. { cards ∷ CardRepo | ctx } -> String -> Effect Unit
parseAndSaveCards { cards } str = do
  let
    parsed = readJSON str ∷ _ (Array Card)
  either
    (intercalateMap ",\n" renderForeignError >>> log)
    (traverse_ cards.write)
    parsed

newtype Mana
  = Mana
  { colourless ∷ Maybe Int
  , blue ∷ Maybe Int
  , black ∷ Maybe Int
  , white ∷ Maybe Int
  , green ∷ Maybe Int
  , red ∷ Maybe Int
  , x ∷ Maybe Int
  }

addMaybeMana ∷ Maybe Int -> Maybe Int -> Maybe Int
addMaybeMana = case _, _ of
  Nothing, Nothing -> Nothing
  Just n, Nothing -> Just n
  Nothing, Just m -> Just m
  Just n, Just m -> Just (n + m)

fillUp ∷
  ∀ small missing r.
  Nub r r =>
  Union small missing r =>
  Monoid (Record missing) =>
  Record small ->
  Record r
fillUp small = disjointUnion small mempty

fillUp2 ∷
  ∀ small missing r.
  Nub r r =>
  WriteForeign (Record small) =>
  ReadForeign (Record r) =>
  Union small missing r =>
  Record small ->
  Record r
fillUp2 r = either (\_ -> unsafeCrashWith "No way") identity (JSON.readJSON (JSON.writeJSON r))

instance monoidMana ∷ Monoid Mana where
  mempty =
    Mana
      { colourless: Nothing
      , blue: Nothing
      , black: Nothing
      , white: Nothing
      , green: Nothing
      , red: Nothing
      , x: Nothing
      }

noMana ∷ Mana
noMana = mempty

instance semigroupMana ∷ Semigroup Mana where
  append (Mana m1) (Mana m2) =
    Mana
      { colourless: addMaybeMana m1.colourless m2.colourless
      , blue: addMaybeMana m1.blue m2.blue
      , black: addMaybeMana m1.black m2.black
      , white: addMaybeMana m1.white m2.white
      , green: addMaybeMana m1.green m2.green
      , red: addMaybeMana m1.red m2.red
      , x: addMaybeMana m1.x m2.x
      }

toConvertedManaCost ∷ Mana -> Int
toConvertedManaCost ( Mana
    { colourless
  , blue
  , black
  , white
  , green
  , red
  }
) = foldr (fromMaybe 0 >>> (+)) 0 [ colourless, blue, black, white, green, red ]

instance showMana ∷ Show Mana where
  show (Mana m) =
    let
      printColourless = maybe "" \x -> "{" <> show x <> "}"

      p col = maybe "" \x -> fold (replicate x ("{" <> col <> "}"))
    in
      printColourless m.colourless
        <> p "U" m.blue
        <> p "B" m.black
        <> p "W" m.white
        <> p "G" m.green
        <> p "R" m.red

curlies ∷ ∀ m a. Monad m => ParserT String m a -> ParserT String m a
curlies = between (string "{") (string "}")

digit ∷ ∀ m s. Monad m => StringLike s => ParserT s m Int
digit =
  (string "0" >>= \_ -> pure 0)
    <|> (string "1" >>= \_ -> pure 1)
    <|> (string "2" >>= \_ -> pure 2)
    <|> (string "3" >>= \_ -> pure 3)
    <|> (string "4" >>= \_ -> pure 4)
    <|> (string "5" >>= \_ -> pure 5)
    <|> (string "6" >>= \_ -> pure 6)
    <|> (string "7" >>= \_ -> pure 7)
    <|> (string "8" >>= \_ -> pure 8)
    <|> (string "9" >>= \_ -> pure 9)

digitsToInt ∷ ∀ f. Foldable f => f Int -> Int
digitsToInt = _.acc <<< foldr f { pos: 1, acc: 0 }
  where
  f d { pos, acc } = { pos: pos * 10, acc: d * pos + acc }

mana ∷ ∀ m. Monad m => ParserT String m Mana
mana = do
  (string "U" <#> const (Mana (fillUp2 { blue: Just 1 })))
    <|> (string "B" <#> const (Mana (fillUp2 { black: Just 1 })))
    <|> (string "G" <#> const (Mana (fillUp2 { green: Just 1 })))
    <|> (string "R" <#> const (Mana (fillUp2 { red: Just 1 })))
    <|> (string "W" <#> const (Mana (fillUp2 { white: Just 1 })))
    <|> ((many digit) <#> (\digits -> Mana (fillUp2 { colourless: Just (digitsToInt digits) })))

parseConvertedManaCost ∷ String -> Either ParseError Mana
parseConvertedManaCost s = fold <$> (runParser s (many (curlies mana)))
