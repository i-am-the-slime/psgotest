module Effect.Goroutine where

import Prelude

import Data.Either (Either(..))
import Data.Foldable (oneOf, traverse_)
import Data.Maybe (Maybe(..))
import Data.Traversable (sequence_)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Uncurried (EffectFn3, runEffectFn3)
import Effect.Unsafe (unsafePerformEffect)
import Partial.Unsafe (unsafeCrashWith)
import Unsafe.Coerce (unsafeCoerce)

foreign import fireAndForget ∷ Effect Unit -> Effect Unit

foreign import data WaitGroup ∷ Type
foreign import data Channel ∷ Type

foreign import waitGroup ∷ Effect WaitGroup

foreign import blocking ∷ ∀ a. WaitGroup -> Effect a -> Effect Unit
foreign import mkChannel ∷ Effect Channel
foreign import send ∷ ∀ a. Channel -> a -> Effect Unit
foreign import receive ∷ ∀ a. Channel -> Effect a
foreign import go ∷ Effect Unit -> Effect Unit
foreign import sleepImpl ∷ Int -> Effect Unit

foreign import httpReqImpl ∷
  (String -> Either String String) ->
  (String -> Either String String) ->
  String ->
  Effect (Either String String)

httpReq ∷ String -> Effect (Either String String)
httpReq = httpReqImpl Left Right

newtype Go a = Go (Effect a)

toEffect ∷ ∀ a. Go a -> Effect a
toEffect (Go x) = x

sleep ∷ ∀ f. MonadEffect f => Int -> f Unit
sleep = liftEffect <<< sleepImpl

async ∷ ∀ a. Effect a -> Go a
async eff = Go do
  c <- mkChannel
  go $ eff >>= send c
  receive c

parAsync ∷ ∀ a b. Effect a -> Effect b -> Go (Tuple a b)
parAsync eff1 eff2 = Go do
  c <- mkChannel
  go $ eff1 >>= Right >>> send c
  go $ eff2 >>= Left >>> send c
  res1 <- receive c
  res2 <- receive c
  case res1, res2 of
    Left r1, Right r2 -> pure (Tuple r1 r2)
    Right r2, Left r1 -> pure (Tuple r1 r2)
    _,_ -> unsafeCrashWith "Impossible channel state"

race ∷ ∀ a b. Effect a -> Effect a -> Go a
race eff1 eff2 = Go do
  c <- mkChannel
  go $ eff1 >>= send c
  go $ eff2 >>= send c
  receive c

apathise ∷ ∀ a. Go a -> Effect Unit
apathise x = do
  _ <- pure (unsafePerformEffect (toEffect x))
  pure unit

dunno ∷ ∀ a. a
dunno = unsafeCoerce ""

instance functorGo ∷ Functor Go where
  map f (Go eff) = Go (map f eff)

instance applicativeGo ∷ Applicative Go where
  pure = Go <<< pure

instance applyGo ∷ Apply Go where
  apply ∷ ∀ a b. Go (a -> b) -> Go a -> Go b
  apply (Go f) (Go a) = Go (apply f a)

instance bindGo ∷ Bind Go where
  bind (Go first) f = Go do
    frst <- first
    toEffect (f frst)

instance monadGo ∷ Monad Go

instance monadEffectGo ∷ MonadEffect Go where
  liftEffect = Go
