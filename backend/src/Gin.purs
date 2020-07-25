module Gin where

import Prelude
import Cards.Types (CardRepo)
import Control.Monad.RWS (RWST(..), lift)
import Control.Monad.Reader (ReaderT(..), runReader, runReaderT)
import Control.Monad.Trans.Class (class MonadTrans)
import Data.Either (either)
import Data.Foldable (foldMap)
import Data.Newtype (class Newtype, overF)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Effect.Unsafe (unsafePerformEffect)
import Foreign (Foreign, renderForeignError)
import Simple.JSON (class ReadForeign, class WriteForeign, E)
import Simple.JSON as Json

foreign import data Gin ∷ Type

foreign import data GinCtx ∷ Type

foreign import data GinHandler ∷ Type

foreign import mkDefaultGin ∷ Effect Gin

foreign import mkHandler ∷ (GinCtx -> Unit) -> GinHandler

newtype HandlerM a
  = HandlerM (ReaderT GinCtx Effect a)
derive instance ntHandlerM ∷ Newtype (HandlerM a) _
derive newtype instance bindHandlerM ∷ Bind HandlerM
derive newtype instance monadHandlerM ∷ Monad HandlerM
derive newtype instance monadEffectHandlerM ∷ MonadEffect HandlerM

toGinHandler ∷ HandlerM Unit -> GinHandler
toGinHandler (HandlerM h) = mkHandler (unsafePerformEffect <<< runReaderT h)

newtype AppM a
  = AppM (ReaderT Gin Effect a)
derive instance ntAppM ∷ Newtype (AppM a) _
derive newtype instance bindAppM ∷ Bind AppM
derive newtype instance monadAppM ∷ Monad AppM

foreign import staticImpl ∷ Gin -> String -> String -> Effect Unit

static ∷ String -> String -> AppM Unit
static route folder = AppM <<< ReaderT $ \gin -> staticImpl gin route folder

foreign import noRouteImpl ∷ Gin -> GinHandler -> Effect Unit

noRoute ∷ HandlerM Unit -> AppM Unit
noRoute handler = AppM <<< ReaderT $ \gin -> noRouteImpl gin (toGinHandler handler)

foreign import getImpl ∷ Gin -> String -> GinHandler -> Effect Unit

get ∷ String -> HandlerM Unit -> AppM Unit
get str h = AppM <<< ReaderT $ \gin -> getImpl gin str (toGinHandler h)

foreign import postImpl ∷ Gin -> String -> GinHandler -> Effect Unit

post ∷ String -> HandlerM Unit -> AppM Unit
post str h = AppM <<< ReaderT $ \gin -> postImpl gin str (toGinHandler h)

-- | Handler
ginCtxToUnitToHandler ∷ ∀ a. (GinCtx -> a) -> HandlerM a
ginCtxToUnitToHandler f = HandlerM (ReaderT (pure <$> f))

foreign import sendFileImpl ∷ String -> GinCtx -> Unit

sendFile ∷ String -> HandlerM Unit
sendFile = ginCtxToUnitToHandler <<< sendFileImpl

foreign import getBodyImpl ∷ GinCtx -> Foreign

getBody ∷ ∀ r. ReadForeign { | r } => HandlerM (E { | r })
getBody = HandlerM <<< ReaderT $ pure <$> (Json.read <<< getBodyImpl)

foreign import sendJsonImpl ∷ Int -> Foreign -> GinCtx -> Unit

sendJson ∷ ∀ r. WriteForeign (Record r) => Int -> Record r -> HandlerM Unit
sendJson status r = ginCtxToUnitToHandler (sendJsonImpl status (Json.write r))

foreign import runImpl ∷ EffectFn1 Gin Unit

run ∷ AppM Unit -> Gin -> Effect Unit
run (AppM app) g = do
  runReaderT app g
  runEffectFn1 runImpl g
