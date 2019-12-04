module Card.Component where

import Prelude

import Cards.Types (Card)
import Data.Either (either)
import Effect (Effect)
import Effect.Class (liftEffect)
import Milkis (defaultFetchOptions)
import Milkis as M
import Network.RemoteData as RD
import React.Basic.DOM as R
import React.Basic.Hooks (ReactComponent, component, useState, (/\))
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)
import Simple.JSON as JSON
import Debug.Trace (spy)

mkCard :: { fetch ∷ M.Fetch } -> Effect (ReactComponent {})
mkCard { fetch } = do
  component "Card" \props -> React.do
    cards /\ setCards <- useState (RD.NotAsked ∷ _ { cards :: Array Card })
    useAff unit do
      liftEffect $ setCards (const RD.Loading)
      res <- fetch (M.URL "/api/cards") defaultFetchOptions
      stuff <- M.json res
      liftEffect $ setCards (const (JSON.read stuff # either RD.Failure RD.Success))

    pure case cards of
      RD.NotAsked -> (R.text "Not Asked")
      RD.Loading -> (R.text "Loading")
      RD.Failure f -> (R.text $ show f)
      RD.Success cs ->
        R.ul_ ((spy "cs" cs).cards <#> \card -> (R.text $ show card.name))

