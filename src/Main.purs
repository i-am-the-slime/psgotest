module Main where

import Prelude

import Data.Array (length, take, (!!))
import Data.Bifunctor (lmap)
import Data.Either (Either, either)
import Data.Foldable (for_, traverse_)
import Data.Int (floor)
import Data.Maybe (Maybe, fromMaybe)
import Data.Semigroup.Foldable (intercalateMap)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Class.Console (log, logShow)
import Effect.Goroutine (Go(..), apathise, async, blocking, fireAndForget, go, httpReq, mkChannel, parAsync, race, receive, send, sleep, toEffect, waitGroup)
import Effect.Random (random)
import Elasticsearch as ES
import Foreign (renderForeignError)
import Simple.JSON (readJSON, writeJSON)
import Simple.JSON as JSON



main :: Effect Unit
main = do
  ctx <- mkLiveCtx
  httpReq "http://localhost:8081/scryfall-default-cards.json"
      >>= either log (parseAndSaveCards ctx)

type CardRepo =
  { write ∷ Card -> Effect Unit
  }
type Ctx = { cards ∷ CardRepo }

mkLiveCtx = do
  cards <- mkElasticSearchCardRepo
  pure {
    cards
  }

mkElasticSearchCardRepo ∷ Effect CardRepo
mkElasticSearchCardRepo = do
  client <- ES.mkDefaultClient
  info <- ES.info client
  logShow info
  pure { write: \(card ∷ Card) -> do
              let req = ES.mkIndexRequest
                            (ES.Index "cards")
                            (ES.DocId card.id)
                            (ES.Body (writeJSON card))
              void $ ES.index client req
            }

parseAndSaveCards :: ∀ ctx. { cards ∷ CardRepo } -> String -> Effect Unit
parseAndSaveCards { cards } str = do
  let (parsed ∷ _ (Array Card)) = readJSON str
  either
    (intercalateMap ",\n" renderForeignError >>> log)
    (traverse_ cards.write)
    parsed

type ImageUris
  = { art_crop :: String
    , border_crop :: String
    , large :: String
    , normal :: String
    , png :: String
    , small :: String
    }

type Legalities
  = { brawl :: String
    , commander :: String
    , duel :: String
    , future :: String
    , historic :: String
    , legacy :: String
    , modern :: String
    , oldschool :: String
    , pauper :: String
    , penny :: String
    , pioneer :: String
    , standard :: String
    , vintage :: String
    }

type RelatedUris =
      { edhrec :: String
      , mtgtop8 :: String
      , tcgplayer_decks :: String
      }

type Card
  = { artist :: String
    , artist_ids :: Maybe (Array String)
    , booster :: Boolean
    , border_color :: String
    , card_back_id :: String
    , cmc :: Number
    , collector_number :: String
    , color_identity :: Array String
    , colors :: Maybe (Array String)
    , digital :: Boolean
    , flavor_text :: Maybe String
    , foil :: Boolean
    , frame :: String
    , full_art :: Boolean
    , games :: Array String
    , highres_image :: Boolean
    , id :: String
    , illustration_id :: Maybe String
    , image_uris :: Maybe ImageUris
    , lang :: String
    , layout :: String
    , legalities :: Legalities
    , mana_cost :: Maybe String
    , multiverse_ids :: Array Int
    , name :: String
    , nonfoil :: Boolean
    , object :: String
    , oracle_id :: String
    , oracle_text :: Maybe String
    , oversized :: Boolean
    , power :: Maybe String
    , prints_search_uri :: String
    , promo :: Boolean
    , rarity :: String
    , related_uris :: RelatedUris
    , released_at :: String
    , reprint :: Boolean
    , reserved :: Boolean
    , rulings_uri :: String
    , scryfall_set_uri :: String
    , scryfall_uri :: String
    , set :: String
    , set_name :: String
    , set_search_uri :: String
    , set_type :: String
    , set_uri :: String
    , story_spotlight :: Boolean
    , tcgplayer_id :: Maybe Int
    , textless :: Boolean
    , toughness :: Maybe String
    , type_line :: String
    , uri :: String
    , variation :: Boolean
    }
