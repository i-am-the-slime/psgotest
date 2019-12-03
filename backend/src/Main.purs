module Main where

import Prelude

import Cards.Service (parseConvertedManaCost, toConvertedManaCost)
import Context (mkLiveCtx)
import Data.Array (zip)
import Data.Bifunctor (lmap)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Class.Console (logShow)
import Simple.JSON as JSON
import Gin (server)

main ∷ Effect Unit
main = do
  ctx <- mkLiveCtx
  res <- ctx.cards.search
  server
  let
    boy = do
      (results ∷ Result CardRes) <- JSON.read res # lmap show
      let cards = results.hits.hits <#> _._source
      let manaCosts = cards <#> _.mana_cost
      let names = cards <#> _.name
      let images = cards <#> _.image_uris.large
      parsedManaCosts <- traverse parseConvertedManaCost manaCosts # lmap show

      pure $ (toConvertedManaCost <$> parsedManaCosts) `zip` names `zip` images
  logShow boy

type CardRes
  = { mana_cost ∷ String
    , name ∷ String
    , oracle_text ∷ String
    , set_name ∷ String
    , image_uris ∷ { large ∷ String }
    }

-- httpReq "http://localhost:8081/scryfall-default-cards.json"
--     >>= either log (parseAndSaveCards ctx)
type Result a
  = { _shards ∷
      { failed ∷ Int
      , skipped ∷ Int
      , successful ∷ Int
      , total ∷ Int
      }
    , hits ∷
      { hits ∷
        Array
          { _id ∷ String
          , _index ∷ String
          , _score ∷ Number
          , _source ∷ a
          , _type ∷ String
          }
      , max_score ∷ Number
      , total ∷
        { relation ∷ String
        , value ∷ Int
        }
      }
    , timed_out ∷ Boolean
    , took ∷ Int
    }
