module Main where

import Prelude

import API (server)
import Cards.Service (parseAndSaveCards)
import Context (mkLiveCtx)
import Data.Either (either)
import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Goroutine (httpReq)

main ∷ Effect Unit
main = do
  ctx <- mkLiveCtx 
  httpReq "http://localhost:8081/scryfall-default-cards.json"
    >>= either log (parseAndSaveCards ctx)
  server ctx

