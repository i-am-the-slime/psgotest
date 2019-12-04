module Gin where

import Prelude

import Cards.Types (CardRepo)
import Data.Either (either)
import Data.Foldable (foldMap)
import Effect (Effect)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Effect.Unsafe (unsafePerformEffect)
import Foreign (Foreign, renderForeignError)
import Simple.JSON (class ReadForeign, class WriteForeign, E)
import Simple.JSON as Json

foreign import data Gin ∷ Type

foreign import data Ctx ∷ Type

foreign import data Handler ∷ Type

foreign import mkDefaultGin ∷ Effect Gin

foreign import mkHandler ∷ (Ctx -> Unit) -> Handler

foreign import static ∷ Gin -> String -> String -> Effect Unit

foreign import noRoute ∷ Gin -> Handler -> Effect Unit

foreign import getImpl ∷ Gin -> String -> Handler -> Effect Unit

foreign import postImpl ∷ Gin -> String -> Handler -> Effect Unit

get ∷ Gin -> String -> Handler -> Effect Unit
get gin str f = getImpl gin str f

post ∷ Gin -> String -> Handler -> Effect Unit
post gin str f = postImpl gin str f

foreign import runImpl ∷ EffectFn1 Gin Unit

foreign import sendJsonImpl ∷ Int -> Foreign -> Ctx -> Unit

foreign import getBodyImpl ∷ Ctx -> Foreign

foreign import sendFileImpl ∷ String -> Ctx -> Unit

getBody ∷ ∀ r. ReadForeign { | r } => Ctx -> E { | r }
getBody = Json.read <<< getBodyImpl

sendJson ∷ ∀ r. WriteForeign (Record r) => Int -> Record r -> Ctx -> Unit
sendJson c r = sendJsonImpl c (Json.write r)

run ∷ Gin -> Effect Unit
run = runEffectFn1 runImpl

handler ∷ Handler
handler = mkHandler $ getBody >>= sendResponse

cardHandler ∷ ∀ r. { cards ∷ CardRepo } -> Handler
cardHandler { cards } =
  mkHandler \ctx ->
    sendJson 200 { cards: unsafePerformEffect cards.search } ctx

sendResponse ∷ E { holz ∷ String } -> Ctx -> Unit
sendResponse =
  either
    (foldMap renderForeignError >>> { error: _ } >>> sendJson 400)
    (sendJson 200)

server ∷ ∀ r. { cards ∷ CardRepo } -> Effect Unit
server ctx = do
  gin <- mkDefaultGin
  get gin "/api/cards" (cardHandler ctx )
  post gin "/pog" handler
  static gin "/assets" "./assets"
  noRoute gin (mkHandler (sendFileImpl "index.html"))
  run gin
