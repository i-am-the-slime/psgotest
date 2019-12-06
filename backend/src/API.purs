module API where

import Prelude

import Cards.Handler (cardHandler)
import Cards.Types (CardRepo)
import Effect (Effect)
import Gin (mkDefaultGin, noRoute, post, run, sendFile, static)

server ∷ ∀ r. { cards ∷ CardRepo | r } -> Effect Unit
server ctx = do
  gin <- mkDefaultGin
  let
    app = do
      post "/api/cards" $ cardHandler ctx
      static "/assets" "./assets"
      noRoute $ sendFile "index.html"
  run app gin 