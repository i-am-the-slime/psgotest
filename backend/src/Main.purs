module Main where

import Prelude

import API (server)
import Context (mkLiveCtx)
import Effect (Effect)

main ∷ Effect Unit
main = mkLiveCtx >>= server

-- httpReq "http://localhost:8081/scryfall-default-cards.json"
--     >>= either log (parseAndSaveCards ctx)
