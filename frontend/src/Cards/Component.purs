module Cards.Component where

import Prelude
import Card.Component (mkCard)
import Cards.Types (Card)
import Data.Array (nubByEq)
import Data.Array as A
import Data.Date (Date)
import Data.Date as DT
import Data.Either (either)
import Data.Enum (class BoundedEnum, toEnum)
import Data.Foldable (indexl)
import Data.Int as Int
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (Pattern(..), split)
import Data.Traversable (for_, traverse)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Milkis (postMethod)
import Milkis as M
import Network.RemoteData as RD
import React.Basic (element)
import React.Basic.DOM (CSS, css)
import React.Basic.DOM as R
import React.Basic.DOM.Events (preventDefault, targetValue)
import React.Basic.Events (handler)
import React.Basic.Hooks (ReactComponent, component, fragment, useState, (/\))
import React.Basic.Hooks as React
import React.JSS (createUseStyles_)
import Simple.JSON (writeJSON)
import Simple.JSON as JSON

type CardsClasses
  = { ul ∷ CSS, input ∷ CSS }

cardsStyles ∷ CardsClasses
cardsStyles =
  { ul:
    css
      { listStyleType: "none"
      }
  , input:
    css
      { backgroundColor: "#d6d9dd"
      , border: "solid 1px #5e3316"
      , borderRadius: "50px"
      , marginTop: "4px"
      , marginBottom: "4px"
      , marginLeft: "7px"
      , marginRight: "7px"
      , paddingLeft: "40px"
      , paddingRight: "40px"
      , paddingTop: "6px"
      , paddingBottom: "6px"
      , fontSize: "64pt"
      }
  }

mkCards ∷ { fetch ∷ M.Fetch } -> Effect (ReactComponent {})
mkCards { fetch } = do
  useStyles <- createUseStyles_ cardsStyles
  cardC <- mkCard
  component "Cards" \props -> React.do
    classes <- useStyles
    input /\ setInput <- useState ""
    cards /\ setCards <- useState RD.NotAsked
    let
      getCard = mkGetCard setCards input
      renderList children = R.ul { className: classes.ul, children }
      renderCards = renderList <<< map (\c -> R.li_ [ element cardC { card: c } ])
    pure
      $ fragment
          [ R.form
              { onSubmit: handler preventDefault (const (launchAff_ getCard))
              , children:
                [ R.input
                    { value: input
                    , onChange: handler targetValue (\x -> for_ x (setInput <<< const))
                    , className: classes.input
                    }
                ]
              }
          , case cards of
              RD.NotAsked -> R.text "Search"
              RD.Loading -> R.text "Loading"
              RD.Failure f -> R.text (show f)
              RD.Success cs -> renderCards cs
          ]
  where
  mkGetCard setCards input = do
    liftEffect $ setCards (const RD.Loading)
    let
      body = writeJSON { q: input }
      options = { method: postMethod, body }
    res <- fetch (M.URL "/api/cards") options
    parsed ∷ _ { cards ∷ Array Card } <- M.json res <#> JSON.read
    let
      cards = parsed <#> _.cards <#> nubByEq (\x y -> x.name == y.name) # either RD.Failure RD.Success
    liftEffect $ setCards (const cards)

type IndexDate
  = { name ∷ String, date ∷ DT.Date }

parse ∷ String -> Maybe IndexDate
parse name = { name, date: _ } <$> maybeDate
  where
  parsed = name # split (Pattern "_") # A.takeEnd 3
  maybeDate = case parsed of
    [ year, month, day ] -> join $
      DT.exactDate <$> strToEnum year <*> strToEnum month <*> strToEnum day
    _ -> Nothing

  strToEnum ∷ ∀ e. BoundedEnum e => String -> Maybe e
  strToEnum = Int.fromString >=> toEnum
