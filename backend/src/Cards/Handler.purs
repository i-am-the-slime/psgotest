module Cards.Handler where

import Prelude

import Cards.Types (CardRepo)
import Data.Either (Either(..))
import Effect.Class (liftEffect)
import Gin (HandlerM, getBody, sendJson)

cardHandler ∷ ∀ r. { cards ∷ CardRepo | r } -> HandlerM Unit
cardHandler { cards } = do
  body <- getBody
  case body of
    Right ({ q } ∷ { q ∷ String }) -> do
      result <- cards.search q # liftEffect
      sendJson 200 { cards: result }
    Left e -> do
      sendJson 400 { "error": "your json is wrong" }
