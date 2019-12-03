module Gin where

import Prelude

import Data.Either (either)
import Data.Foldable (foldMap)
import Effect (Effect)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Foreign (Foreign, renderForeignError)
import Simple.JSON (class ReadForeign, class WriteForeign, E)
import Simple.JSON as Json

foreign import data Gin ∷ Type

foreign import data Ctx ∷ Type

foreign import data Handler ∷ Type

foreign import mkDefaultGin ∷ Effect Gin

foreign import mkHandler ∷ (Ctx -> Unit) -> Handler

foreign import getImpl ∷ Gin -> String -> Handler -> Effect Unit

foreign import postImpl ∷ Gin -> String -> Handler -> Effect Unit

get ∷ Gin -> String -> Handler -> Effect Unit
get gin str f = getImpl gin str f

post ∷ Gin -> String -> Handler -> Effect Unit
post gin str f = postImpl gin str f

foreign import runImpl ∷ EffectFn1 Gin Unit

foreign import sendJsonImpl ∷ Int -> Foreign -> Ctx -> Unit

foreign import getBodyImpl ∷ Ctx -> Foreign

getBody ∷ ∀ r. ReadForeign { | r } => Ctx -> E { | r }
getBody = Json.read <<< getBodyImpl

sendJson ∷ ∀ r. WriteForeign (Record r) => Int -> Record r -> Ctx -> Unit
sendJson c r = sendJsonImpl c (Json.write r)

run ∷ Gin -> Effect Unit
run = runEffectFn1 runImpl

handler ∷ Handler
handler = mkHandler $ getBody >>= sendResponse

sendResponse ∷ E { holz ∷ String } -> Ctx -> Unit
sendResponse =
  either
    (foldMap renderForeignError >>> { error: _ } >>> sendJson 400)
    (sendJson 200)

server ∷ Effect Unit
server = do
  gin <- mkDefaultGin
  post gin "/pog" handler
  run gin
