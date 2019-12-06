module Card.Component where

import Prelude

import Cards.Types (Card)
import Data.Either (either)
import Data.Traversable (for_)
import Data.Maybe (fromMaybe)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Milkis (postMethod)
import Milkis as M
import Network.RemoteData as RD
import React.Basic.DOM as R
import React.Basic.DOM.Events (preventDefault, targetValue)
import React.Basic.Events (handler)
import React.Basic.Hooks (ReactComponent, component, useState, (/\))
import React.Basic.Hooks as React
import Simple.JSON (writeJSON)
import Simple.JSON as JSON

mkCard :: { fetch ∷ M.Fetch } -> Effect (ReactComponent {})
mkCard { fetch } = do
  component "Card" \props -> React.do
    input /\ setInput <- useState ""
    cards /\ setCards <- useState (RD.NotAsked ∷ _ { cards :: Array Card })
    let
      getCard = do
        liftEffect $ setCards (const RD.Loading)
        let
          body = writeJSON { q: input }
          options = { method: postMethod, body }
        res <- fetch (M.URL "/api/cards") options
        stuff <- M.json res
        liftEffect $ setCards (const (JSON.read stuff # either RD.Failure RD.Success))
    pure case cards of
      RD.NotAsked ->
        R.form
          { onSubmit: handler preventDefault (\_ -> launchAff_ getCard)
          , children: [ R.input { value: input, onChange: handler targetValue (\x -> for_ x (setInput <<< const)) } ]
          }
      RD.Loading -> (R.text "Loading")
      RD.Failure f -> (R.text $ show f)
      RD.Success cs -> R.ul_ (cs.cards <#> \card -> (R.img { src: card.image_uris <#> _.small # fromMaybe "" }))
