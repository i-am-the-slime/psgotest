module Main where

import Prelude
import Cards.Component (mkCards)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import Milkis (fetch)
import Milkis.Impl.Window (windowFetch)
import React.Basic (element)
import React.Basic.DOM (render)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

main ∷ Effect Unit
main = do
  container <- getElementById "container" =<< (map toNonElementParentNode $ document =<< window)
  case container of
    Nothing -> throw "Container element not found."
    Just c -> do
      card <- mkCards { fetch: fetch windowFetch }
      let
        app = element card {}
      render app c
